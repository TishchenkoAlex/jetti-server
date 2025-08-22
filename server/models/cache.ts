
interface CacheStorage {
    get: (key: string) => any,
    set: <T = any>(key: string, value: T) => void,
}

interface Updater<T = any> {
    event: string,
    handler: () => Promise<T>
}

export class JCache implements CacheStorage {

    private readonly _updaters: Map<string, Updater['handler']> = new Map;

    constructor(private readonly storage: CacheStorage, updaters: Updater[]) {
        updaters.forEach(this.registerUpdater.bind(this));
    }

    async init() {
        await Promise.all([...this._updaters.keys()].map(e => this.update(e)));
        return this;
    }

    async update(event: string) {
        const updater = this._updaters.get(event);
        if (!updater) return console.error(`[JCache.update] updater is not registered for event: "${event}"`);
        this.set(event, await this._updaters.get(event)?.());
    }

    registerUpdater({ event, handler }: Updater) {
        this._updaters.set(event, handler);
    }

    get<T = any>(key: string) {
        return this.storage.get(key) as T | undefined;
    };

    set(key: string, value: any) {
        console.info('[JCache.set]', key);
        this.storage.set(key, value);
    };
}