import { Boom } from '@hapi/boom'
import NodeCache from '@cacheable/node-cache'
import makeWASocket, {
    AnyMessageContent,
    delay,
    DisconnectReason,
    fetchLatestBaileysVersion, 
    isJidGroup,
    isJidNewsletter,
    makeCacheableSignalKeyStore,
    proto,
    useMultiFileAuthState,
    WAMessageKey,
    WASocket,
    Browsers,
    jidNormalizedUser 
} from '../src' 
import fs from 'fs'
import path from 'path' 
import P, { Logger } from 'pino' 
import express, { Express } from 'express'
import cors from 'cors'
import sqlite3 from 'sqlite3'
import { open, Database } from 'sqlite'
import fetch from 'node-fetch'

const logger: Logger = P({ 
    // enabled: false, 
    // transport: { 
    //   target: 'pino-pretty',
    //   options: { colorize: true, translateTime: 'SYS:standard', ignore: 'pid,hostname'}
    // }
})
logger.level = 'trace'; 

const msgRetryCounterCache = new NodeCache()

async function getBaileysVersion(): Promise<[number, number, number]> {
    try {
        const response = await fetch(
            "https://raw.githubusercontent.com/WhiskeySockets/Baileys/master/src/Defaults/baileys-version.json"
        );
        if (!response.ok) {
            throw new Error(`Failed to fetch Baileys version: ${response.statusText}`);
        }
        const jsonResponse = await response.json() as any; 
        if (!jsonResponse || !Array.isArray(jsonResponse.version) || jsonResponse.version.length < 3) {
            throw new Error('Invalid version format fetched');
        }
        return jsonResponse.version;
    } catch (error) {
        console.error("Failed to fetch Baileys version from GitHub, falling back to fetchLatestBaileysVersion", error);
        const { version } = await fetchLatestBaileysVersion(); 
        return version;
    }
}

function removeAuthDir(phoneNumber: string): void {
    const authDir = `baileys_auth_info_${phoneNumber.replace(/[^0-9]/g, '')}`;
    if (fs.existsSync(authDir)) {
        console.log(`Removing old auth directory: ${authDir}`);
        fs.rm(authDir, { recursive: true, force: true }, (err) => {
            if (err) console.error(`Failed to remove auth directory ${authDir}:`, err);
            else console.log(`Successfully removed auth directory ${authDir}.`);
        });
    }
}

class DatabaseService {
    private db?: Database<sqlite3.Database, sqlite3.Statement>;
    private dbPath: string = './whatsapp_user_data.db';

    constructor() {}

    public async init(): Promise<void> {
        try {
            this.db = await open({
                filename: this.dbPath,
                driver: sqlite3.Database
            });
            console.log('Connected to the SQLite database.');
            await this.setupSchema();
        } catch (error) {
            console.error('Failed to connect to SQLite database.', error);
            throw error;
        }
    }

public async fetchAllDataForDebug(): Promise<{ users: any[], monitored_numbers: any[] }> {
    if (!this.db) {
        throw new Error("Database not initialized");
    }
    try {
        const users = await this.db.all('SELECT * FROM users');
        const monitored_numbers = await this.db.all('SELECT * FROM monitored_numbers');
        return {
            users: users || [],
            monitored_numbers: monitored_numbers || [],
        };
    } catch (error) {
        console.error("Error fetching all data for debug:", error);
        throw error;
    }
}
    private async setupSchema(): Promise<void> {
        if (!this.db) return;
        await this.db.exec(`
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                deviceId TEXT UNIQUE NOT NULL, 
                phoneNumber TEXT UNIQUE,      
                isLoggedIn BOOLEAN NOT NULL DEFAULT FALSE,
                lastKnownJid TEXT,            
                createdAt INTEGER NOT NULL,
                updatedAt INTEGER NOT NULL
            );
        `);
        await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_users_deviceId ON users(deviceId);`);
        await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_users_phoneNumber ON users(phoneNumber);`);
        console.log('User table schema ensured.');

        await this.db.exec(`
            CREATE TABLE IF NOT EXISTS monitored_numbers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ownerUserJid TEXT NOT NULL, 
                monitoredJid TEXT NOT NULL, 
                displayName TEXT,
                isSubscribed BOOLEAN NOT NULL DEFAULT FALSE, 
                lastSeen INTEGER, 
                lastKnownPresence TEXT, 
                createdAt INTEGER NOT NULL,
                updatedAt INTEGER NOT NULL,
                FOREIGN KEY (ownerUserJid) REFERENCES users(lastKnownJid) ON DELETE CASCADE,
                UNIQUE (ownerUserJid, monitoredJid) 
            );
        `);
        await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_monitored_owner ON monitored_numbers(ownerUserJid);`);
        await this.db.exec(`CREATE INDEX IF NOT EXISTS idx_monitored_jid ON monitored_numbers(monitoredJid);`);
        console.log('Monitored numbers table schema ensured.');
    }

    public async upsertUserForPairing(deviceId: string, phoneNumberToPair: string): Promise<{ user: any, oldPhoneNumber?: string | null }> {
        if (!this.db) throw new Error("Database not initialized");
        const now = Date.now();
        const cleanPhoneNumberToPair = phoneNumberToPair.replace(/[^0-9]/g, '');

        const existingUserWithPhoneNumber = await this.db.get(
            'SELECT * FROM users WHERE phoneNumber = ? AND deviceId != ?',
            cleanPhoneNumberToPair, deviceId
        );
        if (existingUserWithPhoneNumber) {
            throw new Error(`Phone number ${cleanPhoneNumberToPair} is already linked to a different device (${existingUserWithPhoneNumber.deviceId}).`);
        }
        
        let oldPhoneNumber: string | null = null;
        let user = await this.db.get('SELECT * FROM users WHERE deviceId = ?', deviceId);

        if (user) { 
            oldPhoneNumber = user.phoneNumber;
            if (oldPhoneNumber && oldPhoneNumber !== cleanPhoneNumberToPair) {
                console.log(`Device ${deviceId} is switching from ${oldPhoneNumber} to ${cleanPhoneNumberToPair}. Old auth files for ${oldPhoneNumber} should be removed by caller.`);
            }
            await this.db.run(
                'UPDATE users SET phoneNumber = ?, isLoggedIn = FALSE, lastKnownJid = NULL, updatedAt = ? WHERE deviceId = ?',
                cleanPhoneNumberToPair, now, deviceId
            );
            user = await this.db.get('SELECT * FROM users WHERE deviceId = ?', deviceId); 
        } else { 
            await this.db.run(
                'INSERT INTO users (deviceId, phoneNumber, isLoggedIn, createdAt, updatedAt) VALUES (?, ?, FALSE, ?, ?)',
                deviceId, cleanPhoneNumberToPair, now, now
            );
            user = await this.db.get('SELECT * FROM users WHERE deviceId = ?', deviceId); 
        }
        console.log(`User record for device ${deviceId} (phoneNumber: ${cleanPhoneNumberToPair}) upserted.`);
        return { user, oldPhoneNumber: oldPhoneNumber !== cleanPhoneNumberToPair ? oldPhoneNumber : null };
    }

    public async updateUserLoginStatus(phoneNumber: string, isLoggedIn: boolean, jid?: string): Promise<void> {
        if (!this.db) throw new Error("Database not initialized");
        const now = Date.now();
        const cleanPhoneNumber = phoneNumber.replace(/[^0-9]/g, '');
        try {
            const result = await this.db.run(
                'UPDATE users SET isLoggedIn = ?, lastKnownJid = ?, updatedAt = ? WHERE phoneNumber = ?',
                isLoggedIn, jid || null, now, cleanPhoneNumber
            );
            if ((result.changes ?? 0) > 0) {
               console.log(`User with phoneNumber ${cleanPhoneNumber} login status updated to ${isLoggedIn}. JID: ${jid}`);
            } else {
                console.warn(`No user found with phoneNumber ${cleanPhoneNumber} to update login status.`);
            }
        } catch (error) {
            console.error('Error updating user login status:', { error, phoneNumber: cleanPhoneNumber, isLoggedIn, jid });
            throw error;
        }
    }
    
    public async getUserRecordByPhoneNumber(phoneNumber: string): Promise<any | null> { 
        if (!this.db) throw new Error("Database not initialized");
        const cleanPhoneNumber = phoneNumber.replace(/[^0-9]/g, '');
        try {
            const user = await this.db.get('SELECT * FROM users WHERE phoneNumber = ?', cleanPhoneNumber);
            return user || null;
        } catch (error) {
            console.error("Error fetching user by phoneNumber:", { error, phoneNumber: cleanPhoneNumber });
            return null;
        }
    }

    public async getUserRecordByDeviceId(deviceId: string): Promise<any | null> { 
        if (!this.db) throw new Error("Database not initialized");
        try {
            const user = await this.db.get('SELECT * FROM users WHERE deviceId = ?', deviceId);
            return user || null;
        } catch (error) {
            console.error("Error fetching user by deviceId:", { error, deviceId });
            return null;
        }
    }

    public async getUserByJid(userJid: string): Promise<any | null> { 
        if (!this.db) throw new Error("Database not initialized");
        try {
            const user = await this.db.get('SELECT * FROM users WHERE lastKnownJid = ?', userJid);
            return user || null;
        } catch (error) {
            console.error("Error fetching user by JID:", { error, userJid });
            return null;
        }
    }

    public async getAllUsers(): Promise<any[] | null> {
        if (!this.db) {
            console.error("Database not initialized in getAllUsers");
            throw new Error("Database not initialized");
        }
        try {
            const users = await this.db.all('SELECT * FROM users');
            return users || []; 
        } catch (error) {
            console.error("Error fetching all users:", error);
            return []; 
        }
    }

    public async addMonitoredNumber(ownerUserJid: string, monitoredJid: string, displayName?: string, isSubscribed: boolean = false): Promise<any> {
        if (!this.db) throw new Error("Database not initialized");
        const now = Date.now();
        try {
            let existing = await this.db.get('SELECT * FROM monitored_numbers WHERE ownerUserJid = ? AND monitoredJid = ?', ownerUserJid, monitoredJid);
            if (existing) {
                await this.db.run(
                    'UPDATE monitored_numbers SET displayName = COALESCE(?, displayName), isSubscribed = ?, updatedAt = ? WHERE id = ?',
                    displayName, isSubscribed, now, existing.id
                );
                console.log(`Monitored number ${monitoredJid} for owner ${ownerUserJid} updated.`);
                return await this.db.get('SELECT * FROM monitored_numbers WHERE id = ?', existing.id);
            } else {
                const result = await this.db.run(
                    'INSERT INTO monitored_numbers (ownerUserJid, monitoredJid, displayName, isSubscribed, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?)',
                    ownerUserJid, monitoredJid, displayName, isSubscribed, now, now
                );
                console.log(`Monitored number ${monitoredJid} added for owner ${ownerUserJid}. Insert ID: ${result.lastID}`);
                return await this.db.get('SELECT * FROM monitored_numbers WHERE id = ?', result.lastID);
            }
        } catch (error: any) {
            if (error.message && error.message.includes('UNIQUE constraint failed')) {
                 console.warn(`Attempted to add monitored number ${monitoredJid} for ${ownerUserJid} which violated a UNIQUE constraint (likely ownerUserJid, monitoredJid pair).`);
                 throw new Error(`Conflict: Monitored JID ${monitoredJid} might already be monitored by this user.`);
            }
            console.error('Error in addMonitoredNumber:', { error, ownerUserJid, monitoredJid });
            throw error;
        }
    }

    public async updateMonitoredNumberSubscription(monitoredJid: string, ownerUserJid: string, isSubscribed: boolean): Promise<void> {
        if (!this.db) throw new Error("Database not initialized");
        const now = Date.now();
        await this.db.run(
            'UPDATE monitored_numbers SET isSubscribed = ?, updatedAt = ? WHERE monitoredJid = ? AND ownerUserJid = ?',
            isSubscribed, now, monitoredJid, ownerUserJid
        );
        console.log(`Subscription status for ${monitoredJid} (owner: ${ownerUserJid}) updated to ${isSubscribed}.`);
    }
    
    public async getMonitoredNumbersByOwner(ownerUserJid: string): Promise<any[]> {
        if (!this.db) throw new Error("Database not initialized");
        try {
            const numbers = await this.db.all('SELECT * FROM monitored_numbers WHERE ownerUserJid = ?', ownerUserJid);
            return numbers || [];
        } catch (error) {
            console.error("Error fetching monitored numbers by owner:", { error, ownerUserJid });
            return [];
        }
    }

    public async getAllSubscribedMonitoredJids(): Promise<string[]> {
        if (!this.db) throw new Error("Database not initialized");
        try {
            const results = await this.db.all<{ monitoredJid: string }[]>(
                'SELECT DISTINCT monitoredJid FROM monitored_numbers WHERE isSubscribed = TRUE'
            );
            return results.map(r => r.monitoredJid);
        } catch (error) {
            console.error("Error fetching all subscribed monitored JIDs:", error);
            return [];
        }
    }
}

const activeUserSessions = new Map<string, WASocket>(); 

async function subscribeToStoredPresences(sock: WASocket, ownerUserJid: string, dbService: DatabaseService) {
    console.log(`[${ownerUserJid}] Attempting to subscribe to presences for already monitored numbers...`);
    const monitoredNumbers = await dbService.getMonitoredNumbersByOwner(ownerUserJid);
    for (const num of monitoredNumbers) {
        if (num.monitoredJid && !num.isSubscribed) { 
            try {
                console.log(`[${ownerUserJid}] Subscribing to presence for ${num.monitoredJid}`);
                await sock.presenceSubscribe(num.monitoredJid);
                await dbService.updateMonitoredNumberSubscription(num.monitoredJid, ownerUserJid, true);
            } catch (err: any) {
                console.error(`[${ownerUserJid}] Failed to subscribe to presence for ${num.monitoredJid}:`, err.message);
                await dbService.updateMonitoredNumberSubscription(num.monitoredJid, ownerUserJid, false);
            }
        } else if (num.monitoredJid && num.isSubscribed) {
            console.log(`[${ownerUserJid}] Already subscribed to presence for ${num.monitoredJid}, ensuring/re-affirming subscription with Baileys.`);
             try {
                await sock.presenceSubscribe(num.monitoredJid); 
            } catch (err: any) {
                console.warn(`[${ownerUserJid}] Error re-affirming presence subscription for ${num.monitoredJid}:`, err.message);
            }
        }
    }
}

async function verifyAndEstablishFinalSession(pairedPhoneNumber: string, dbService: DatabaseService, deviceIdFromUserRecord?: string): Promise<void> {
    const cleanPairedPhoneNumber = pairedPhoneNumber.replace(/[^0-9]/g, '');
    const authDir = `baileys_auth_info_${cleanPairedPhoneNumber}`;
    console.log(`Attempting to verify and establish final session for phoneNumber: ${cleanPairedPhoneNumber}, authDir: ${authDir}, stage: final_init`);

    if (!fs.existsSync(authDir)) {
        console.error(`Auth directory does not exist for final session for ${cleanPairedPhoneNumber}, authDir: ${authDir}, stage: final_init`);
        await dbService.updateUserLoginStatus(cleanPairedPhoneNumber, false); 
        return; 
    }

    const { state, saveCreds } = await useMultiFileAuthState(authDir);

    if (!state.creds?.registered) {
        console.error(`Credentials not registered (or loaded incorrectly) for final session for ${cleanPairedPhoneNumber}, stage: final_init. Auth files might be incomplete or corrupted.`);
        await dbService.updateUserLoginStatus(cleanPairedPhoneNumber, false); 
        return;
    }

    const waVersion = await getBaileysVersion();
    console.log(`Final session for ${cleanPairedPhoneNumber}: Using WA v${waVersion.join('.')}, stage: final_init`);

    const finalSock = makeWASocket({
        version: waVersion,
        logger: logger.child({ session: cleanPairedPhoneNumber, stage: 'final' }), 
        auth: {
            creds: state.creds,
            keys: makeCacheableSignalKeyStore(state.keys, logger.child({ session: cleanPairedPhoneNumber, type: 'signal-store', stage: 'final' })),
        },
        msgRetryCounterCache,
        generateHighQualityLinkPreview: true,
        browser: Browsers.ubuntu('Chrome'), 
    });

    const oldFinalSock = activeUserSessions.get(cleanPairedPhoneNumber);
    if(oldFinalSock) {
        console.warn(`Found old 'final' active session in memory for ${cleanPairedPhoneNumber}. Closing it. Stage: final_init`);
        try { await oldFinalSock.end(new Error('Starting new final session')); } catch (e: any) { console.error(`Error closing old final session for ${cleanPairedPhoneNumber}:`, e.message); }
    }
    activeUserSessions.set(cleanPairedPhoneNumber, finalSock);

    finalSock.ev.on('creds.update', saveCreds);

    finalSock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect } = update;
        const userFullJid = finalSock.user?.id; 
        console.log(`Final session connection update for ${cleanPairedPhoneNumber} (JID: ${userFullJid}): Connection: ${connection}, Error: ${lastDisconnect?.error}, Stage: final`);

        if (connection === 'open') {
            console.log(`FINAL SESSION for user ${cleanPairedPhoneNumber} (JID: ${userFullJid}) connected successfully. Stage: final`);
            if (userFullJid) { 
                await dbService.updateUserLoginStatus(cleanPairedPhoneNumber, true, userFullJid);
                await subscribeToStoredPresences(finalSock, userFullJid, dbService);
            } else {
                console.error(`CRITICAL: Final session opened for ${cleanPairedPhoneNumber} but user JID is not available. Cannot update DB or subscribe to presences.`);
            }
        } else if (connection === 'close') {
            activeUserSessions.delete(cleanPairedPhoneNumber);
            console.log(`FINAL SESSION for user ${cleanPairedPhoneNumber} (JID: ${userFullJid}) closed. Error: ${lastDisconnect?.error}, Stage: final`);
            
            const userRecord = await dbService.getUserRecordByPhoneNumber(cleanPairedPhoneNumber); 
            if (userRecord && userRecord.isLoggedIn) { 
                 await dbService.updateUserLoginStatus(cleanPairedPhoneNumber, false); 
            }
            if ((lastDisconnect?.error as Boom)?.output?.statusCode === DisconnectReason.loggedOut) {
                console.log(`FINAL SESSION user ${cleanPairedPhoneNumber} logged out by WhatsApp. Removing auth files. Stage: final`);
                removeAuthDir(cleanPairedPhoneNumber);
            }
        }
    });

    finalSock.ev.on('presence.update', async ({ id, presences }) => {
        const ownerJidOfThisSocket = finalSock.user?.id; 
        for (const participantJid in presences) {
            if (Object.prototype.hasOwnProperty.call(presences, participantJid)) {
                const presenceUpdate = presences[participantJid]; 
                console.log(
                    `[Presence Update for Owner: ${ownerJidOfThisSocket}] Target JID: ${id}, Participant: ${participantJid}, Presence: ${(presenceUpdate as any)?.presence}, Last Seen: ${(presenceUpdate as any)?.lastSeen}`
                );
            }
        }
    });
}

async function initializeUserSessionForPairing(phoneNumberForPairing: string, dbService: DatabaseService, deviceId: string): Promise<{ sock?: WASocket, pairingCode?: string }> {
    const cleanPhoneNumberForPairing = phoneNumberForPairing.replace(/[^0-9]/g, '');
    const authDir = `baileys_auth_info_${cleanPhoneNumberForPairing}`;
    
    if (fs.existsSync(authDir)) {
        console.log(`Clearing existing auth directory for new pairing attempt: ${authDir}`);
        try {
            fs.rmSync(authDir, { recursive: true, force: true });
        } catch(e) {
            console.error(`Error clearing existing auth directory ${authDir}: `, e);
        }
    }
    if (!fs.existsSync(authDir)) {
        fs.mkdirSync(authDir, { recursive: true });
    }
    
    const { state, saveCreds } = await useMultiFileAuthState(authDir);
    const waVersion = await getBaileysVersion();
    console.log(`Initial pairing session for ${cleanPhoneNumberForPairing}: Using WA v${waVersion.join('.')}`);

    const initialSock = makeWASocket({
        version: waVersion,
        logger: logger.child({ session: cleanPhoneNumberForPairing, stage: 'initial_pairing' }),
        printQRInTerminal: false, 
        auth: {
            creds: state.creds, 
            keys: makeCacheableSignalKeyStore(state.keys, logger.child({ session: cleanPhoneNumberForPairing, type: 'signal-store', stage: 'initial_pairing' })),
        },
        msgRetryCounterCache,
        generateHighQualityLinkPreview: true,
        browser: Browsers.ubuntu('Chrome'),
    });

    let finalSessionLogicInitiated = false; 

    initialSock.ev.on('creds.update', async () => { 
        await saveCreds();
    });

    initialSock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect } = update;
        console.log(`Initial pairing session connection update for ${cleanPhoneNumberForPairing}: Connection: ${connection}, Error: ${lastDisconnect?.error}, Stage: initial_pairing`);

        if (connection === 'open') {
            console.log(`Initial pairing socket connected for ${cleanPhoneNumberForPairing}. JID: ${initialSock.user?.id}, Stage: initial_pairing`);
            if (!finalSessionLogicInitiated && state.creds.registered) { 
                finalSessionLogicInitiated = true;
                console.log(`Proceeding to finalize session for ${cleanPhoneNumberForPairing} after initial connection open and creds registered. Stage: initial_pairing`);
                try {
                    await delay(1000); 
                    await initialSock.logout(); 
                    console.log(`Initial pairing socket logged out for ${cleanPhoneNumberForPairing}. Stage: initial_pairing`);
                } catch (e: any) {
                    console.error(`Error logging out initial pairing socket for ${cleanPhoneNumberForPairing}:`, e.message, `Stage: initial_pairing`);
                }
                verifyAndEstablishFinalSession(cleanPhoneNumberForPairing, dbService, deviceId).catch(err => {
                    console.error(`Error during verifyAndEstablishFinalSession call for ${cleanPhoneNumberForPairing}:`, err);
                });
            } else if (!state.creds.registered) {
                console.warn(`Initial socket opened for ${cleanPhoneNumberForPairing}, but creds not yet registered. Waiting for creds.update. Stage: initial_pairing`);
            }
        } else if (connection === 'close') {
            console.log(`Initial pairing session closed for ${cleanPhoneNumberForPairing}. Error: ${lastDisconnect?.error}, Stage: initial_pairing`);
            if (!finalSessionLogicInitiated && state.creds.registered ) { 
                console.warn(`Initial session closed for ${cleanPhoneNumberForPairing}, but creds WERE registered. Attempting to trigger final session as a fallback. Stage: initial_pairing`);
                finalSessionLogicInitiated = true; 
                verifyAndEstablishFinalSession(cleanPhoneNumberForPairing, dbService, deviceId).catch(err => {
                    console.error(`Error during fallback verifyAndEstablishFinalSession for ${cleanPhoneNumberForPairing}:`, err);
                });
            } else if (!finalSessionLogicInitiated && !state.creds.registered) {
                 console.warn(`Initial pairing session closed for ${cleanPhoneNumberForPairing} before pairing was confirmed by creds.registered. User may need to retry. Stage: initial_pairing`);
            }
        }
    });
    
    try {
        await delay(2000); 
        console.log(`Requesting pairing code for ${cleanPhoneNumberForPairing}. Stage: initial_pairing`);
        const pairingCode = await initialSock.requestPairingCode(cleanPhoneNumberForPairing);
        console.log(`Pairing code requested for ${cleanPhoneNumberForPairing}: ${pairingCode}. Stage: initial_pairing`);
        if (!pairingCode) { 
            throw new Error("requestPairingCode resolved but returned no code.");
        }
        return { sock: initialSock, pairingCode };
    } catch (error: any) {
        console.error(`Failed to request pairing code for ${cleanPhoneNumberForPairing}:`, error.message, `Stage: initial_pairing`);
        try { await initialSock.end(error as Error); } catch (e) {} 
        throw new Error(`Failed to request pairing code from WhatsApp for ${cleanPhoneNumberForPairing}: ${error.message || error}`);
    }
}

class HttpServer {
    private app: Express;
    public readonly port: number; 
    private dbService: DatabaseService;

    constructor(dbService: DatabaseService, port: number = 3000) {
        this.app = express();
        this.port = Number(process.env.PORT) || port;
        this.dbService = dbService;
        this.initializeMiddlewares();
        this.initializeRoutes();
        console.log("HTTP Server class initialized.");
    }

    private initializeMiddlewares(): void {
        this.app.use(cors());
        this.app.use(express.json());
        console.log("HTTP Server middlewares initialized (CORS, JSON).");
    }

    private initializeRoutes(): void {
        this.app.post('/request-pairing-code', async (req, res) => {
            console.log("Received POST /request-pairing-code. Body:", req.body);
            const { phoneNumber: phoneNumberFromRequest, deviceId } = req.body; 

            if (!phoneNumberFromRequest || typeof phoneNumberFromRequest !== 'string') {
                return res.status(400).json({ success: false, message: 'Phone number is required.' });
            }
            if (!deviceId || typeof deviceId !== 'string') {
                return res.status(400).json({ success: false, message: 'Device ID is required.' });
            }

            const cleanPhoneNumberToPair = phoneNumberFromRequest.replace(/[^0-9]/g, '');
            if (!cleanPhoneNumberToPair) {
                return res.status(400).json({ success: false, message: 'Valid phone number is required.' });
            }

            try {
                const { user, oldPhoneNumber } = await this.dbService.upsertUserForPairing(deviceId, cleanPhoneNumberToPair);

                if (oldPhoneNumber) {
                    console.log(`Device ${deviceId} switched from ${oldPhoneNumber} to ${cleanPhoneNumberToPair}. Removing old auth files for ${oldPhoneNumber}.`);
                    removeAuthDir(oldPhoneNumber); 
                    const oldSession = activeUserSessions.get(oldPhoneNumber);
                    if(oldSession) {
                        console.log(`Closing active session for old phone number ${oldPhoneNumber} due to device switch.`);
                        await oldSession.logout(); 
                        activeUserSessions.delete(oldPhoneNumber);
                    }
                }
                
                const actualPhoneNumberForPairing = user.phoneNumber; 
                console.log(`/request-pairing-code: Initializing user session for pairing for ${actualPhoneNumberForPairing} (Device: ${deviceId}).`);
                
                const { pairingCode } = await initializeUserSessionForPairing(actualPhoneNumberForPairing, this.dbService, deviceId);

                if (pairingCode) {
                    return res.status(200).json({ 
                        success: true, 
                        message: 'Pairing code requested. Enter this code on your primary WhatsApp device.', 
                        pairingCode: pairingCode,
                        phoneNumberPaired: actualPhoneNumberForPairing 
                    });
                } else { 
                    throw new Error("initializeUserSessionForPairing did not return a pairing code.");
                }

            } catch (error: any) {
                console.error(`/request-pairing-code: Failed for ${cleanPhoneNumberToPair}, Device ${deviceId}. Error: ${error.message}`);
                return res.status(500).json({ success: false, message: error.message || 'Failed to request pairing code.' });
            }
        });

        this.app.get('/check-login-status/:phoneNumber', async (req, res) => {
            const { phoneNumber } = req.params; 
            console.log(`Received GET /check-login-status/${phoneNumber}`);
            const cleanPhoneNumber = phoneNumber.replace(/[^0-9]/g, '');

            if (!cleanPhoneNumber) {
                return res.status(400).json({ success: false, message: 'Valid phone number parameter is required.' });
            }

            try {
                const user = await this.dbService.getUserRecordByPhoneNumber(cleanPhoneNumber); 
                if (!user) {
                    console.log(`/check-login-status: User not found in DB for phoneNumber ${cleanPhoneNumber}.`);
                    return res.status(404).json({ success: false, isLoggedIn: false, message: 'User pairing process not found or number incorrect.' });
                }
                
                const session = activeUserSessions.get(cleanPhoneNumber); 
                const isActiveFinalSession = !!(session && session.user?.id && session.ws.isOpen);
                
                console.log(`/check-login-status: Status for ${cleanPhoneNumber}. DB LoggedIn: ${user.isLoggedIn}, ActiveSession: ${isActiveFinalSession}, DB JID: ${user.lastKnownJid}, DB DeviceID: ${user.deviceId}`);
                return res.status(200).json({ 
                    success: true, 
                    isLoggedIn: user.isLoggedIn, 
                    isActiveSession: isActiveFinalSession, 
                    jid: user.lastKnownJid, 
                    deviceId: user.deviceId, // Return deviceId associated with this phone number's session
                    message: user.isLoggedIn ? 'User is logged in.' : 'User is not logged in or session not active.'
                });
            } catch (error: any) {
                 console.error(`/check-login-status: Error for ${cleanPhoneNumber}. Error: ${error.message}`);
                 return res.status(500).json({ success: false, isLoggedIn: false, message: 'Error checking login status.' });
            }
        });

        // NEW ENDPOINT: /check-session-by-device/:deviceId
        this.app.get('/check-session-by-device/:deviceId', async (req, res) => {
            const { deviceId } = req.params;
            console.log(`Received GET /check-session-by-device/${deviceId}`);

            if (!deviceId || typeof deviceId !== 'string') {
                return res.status(400).json({ success: false, message: 'Device ID parameter is required.' });
            }

            try {
                const user = await this.dbService.getUserRecordByDeviceId(deviceId);
                if (!user) {
                    console.log(`/check-session-by-device: No user record found for deviceId ${deviceId}.`);
                    return res.status(200).json({ success: true, isLoggedIn: false, message: 'Device not registered or no active session.' });
                }

                // User record exists for this deviceId. Now check if they have a phone number and an active session.
                if (!user.phoneNumber || !user.isLoggedIn || !user.lastKnownJid) {
                    console.log(`/check-session-by-device: Device ${deviceId} found, but no active WhatsApp session linked (phoneNumber: ${user.phoneNumber}, isLoggedIn: ${user.isLoggedIn}).`);
                    return res.status(200).json({ success: true, isLoggedIn: false, message: 'Device registered but no active WhatsApp session linked.' });
                }

                const session = activeUserSessions.get(user.phoneNumber); // Check active Baileys session
                const isActiveBaileysSession = !!(session && session.user?.id && session.ws.isOpen && session.user.id === user.lastKnownJid);

                if (user.isLoggedIn && isActiveBaileysSession) {
                    console.log(`/check-session-by-device: Device ${deviceId} has an active session. JID: ${user.lastKnownJid}, Phone: ${user.phoneNumber}`);
                    return res.status(200).json({
                        success: true,
                        isLoggedIn: true,
                        jid: user.lastKnownJid,
                        phoneNumber: user.phoneNumber, // Number part
                        deviceId: user.deviceId,
                        message: 'Active session found for this device.'
                    });
                } else {
                    console.log(`/check-session-by-device: Device ${deviceId} found. DB isLoggedIn: ${user.isLoggedIn}, Baileys session active: ${isActiveBaileysSession}. No fully active session.`);
                    // If DB says logged in but Baileys session isn't active, update DB.
                    if(user.isLoggedIn && !isActiveBaileysSession) {
                        await this.dbService.updateUserLoginStatus(user.phoneNumber, false, undefined);
                    }
                    return res.status(200).json({ success: true, isLoggedIn: false, message: 'No active session found for this device.' });
                }

            } catch (error: any) {
                console.error(`/check-session-by-device: Error for ${deviceId}. Error: ${error.message}`);
                return res.status(500).json({ success: false, message: 'Error checking device session.' });
            }
        });
        
        this.app.get('/status', (req, res) => {
            console.log("Received GET /status");
            res.status(200).json({
                server: "Baileys Multi-Device Server",
                activeSessions: activeUserSessions.size, 
                activeSessionKeys: Array.from(activeUserSessions.keys())
            });
        });

        this.app.post('/monitor-number', async (req, res) => {
            const { ownerPhoneNumber, numberToMonitor, displayName } = req.body;
            console.log(`Received POST /monitor-number. Owner JID: ${ownerPhoneNumber}, Number to Monitor: ${numberToMonitor}, DisplayName: ${displayName}`);

            if (!ownerPhoneNumber || !numberToMonitor) {
                return res.status(400).json({ success: false, message: "Owner JID and number to monitor are required." });
            }

            const ownerJidNormalized = jidNormalizedUser(ownerPhoneNumber); 
            const ownerNumberPart = ownerJidNormalized.split('@')[0];

            const ownerSession = activeUserSessions.get(ownerNumberPart); 
            if (!ownerSession || !ownerSession.user?.id || ownerSession.user.id !== ownerJidNormalized) {
                return res.status(403).json({ success: false, message: "Owner session not active or JID mismatch. Please log in again." });
            }

            try {
                const results = await ownerSession.onWhatsApp(numberToMonitor); 
                if (!results || results.length === 0 || !results[0]?.exists || !results[0]?.jid) {
                    return res.status(404).json({ success: false, message: `Number ${numberToMonitor} is not on WhatsApp or could not be verified.` });
                }
                const monitoredJid = jidNormalizedUser(results[0].jid); 

                if (!monitoredJid.endsWith('@s.whatsapp.net')) { 
                     return res.status(400).json({ success: false, message: `Cannot monitor non-user JID: ${monitoredJid}` });
                }

                await ownerSession.presenceSubscribe(monitoredJid);
                console.log(`[${ownerJidNormalized}] Successfully subscribed to presence of ${monitoredJid}`);

                await this.dbService.addMonitoredNumber(ownerJidNormalized, monitoredJid, displayName, true);
                
                return res.status(200).json({ success: true, message: `Successfully added ${displayName || monitoredJid} for monitoring and subscribed to presence.` });

            } catch (error: any) {
                console.error(`[${ownerJidNormalized}] Error in /monitor-number for ${numberToMonitor}:`, error);
                return res.status(500).json({ success: false, message: `Failed to monitor number: ${error.message}` });
            }
        });

        this.app.get('/monitored-numbers/:ownerUserJid', async (req, res) => {
            const { ownerUserJid } = req.params; 
            console.log(`Received GET /monitored-numbers/${ownerUserJid}`);

            if (!ownerUserJid) {
                return res.status(400).json({ success: false, message: "Owner JID is required." });
            }
            const normalizedOwnerJid = jidNormalizedUser(ownerUserJid);
            
            try {
                const numbers = await this.dbService.getMonitoredNumbersByOwner(normalizedOwnerJid);
                const resultWithStatus = numbers.map(n => ({
                    id: n.id.toString(), 
                    displayNumber: n.displayName || n.monitoredJid.split('@')[0], 
                    jid: n.monitoredJid,
                    isOnline: n.lastKnownPresence === 'available', 
                }));

                return res.status(200).json({ success: true, data: resultWithStatus });
            } catch (error: any) {
                console.error(`Error fetching monitored numbers for ${normalizedOwnerJid}:`, error);
                return res.status(500).json({ success: false, message: `Failed to fetch monitored numbers: ${error.message}` });
            }
        });

        console.log("HTTP Server routes initialized.");
    }

    public start(): void {
        this.app.listen(this.port, () => {
            console.log(`HTTP Server listening on http://localhost:${this.port}`);
        });
    }
}

async function main() {
    console.log("Application starting...");
    const dbService = new DatabaseService();
    try {
        await dbService.init(); 
        console.log(dbService.fetchAllDataForDebug())
        console.log("Attempting to re-login existing users from database...");
        const allUsers = await dbService.getAllUsers(); 
        if (allUsers && allUsers.length > 0) {
            console.log(`Found ${allUsers.length} user(s) in the database.`);
            for (const user of allUsers) {
                if (user.phoneNumber && user.isLoggedIn) { 
                    const phoneNumber = user.phoneNumber; 
                    const authDir = `baileys_auth_info_${phoneNumber.replace(/[^0-9]/g, '')}`;
                    
                    if (fs.existsSync(authDir)) {
                        console.log(`Auth directory found for ${phoneNumber} (Device: ${user.deviceId}). Attempting to re-establish session.`);
                        verifyAndEstablishFinalSession(phoneNumber, dbService, user.deviceId) 
                            .then(() => {
                                console.log(`Re-login process initiated for ${phoneNumber}. Monitor logs for connection status.`);
                            })
                            .catch(async (err) => { 
                                console.error(`Error initiating re-login for ${phoneNumber}:`, err.message);
                                const currentUserStatus = await dbService.getUserRecordByPhoneNumber(phoneNumber);
                                if (currentUserStatus && currentUserStatus.isLoggedIn) {
                                    await dbService.updateUserLoginStatus(phoneNumber, false);
                                }
                            });
                    } else {
                         console.log(`Auth directory not found for ${phoneNumber} (Device: ${user.deviceId}), but user was marked as logged in. Updating status.`);
                         await dbService.updateUserLoginStatus(phoneNumber, false); 
                    }
                } else if (user.phoneNumber && !user.isLoggedIn) {
                    console.log(`User with phoneNumber ${user.phoneNumber} (Device: ${user.deviceId}) was not marked as loggedIn. Skipping re-login attempt.`);
                } else if (!user.phoneNumber) {
                    console.log(`User with DeviceID ${user.deviceId} has no phone number associated. Skipping re-login attempt.`);
                }
            }
        } else {
            console.log("No existing users found in the database to attempt re-login.");
        }

        const httpServer = new HttpServer(dbService); 
        httpServer.start(); 
        console.log("HTTP server started. Baileys user sessions will be initialized on demand via API or at startup for existing users.");

    } catch (error) {
        console.error('Critical failure during server initialization (DB or HTTP). Application cannot start.', error);
        process.exit(1);
    }
}

main();
