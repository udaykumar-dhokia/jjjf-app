import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Redis } from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private redisClient!: Redis;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const host = this.configService.get<string>('REDIS_HOST') || 'localhost';
    const port = this.configService.get<number>('REDIS_PORT') || 6379;
    
    this.redisClient = new Redis({
      host,
      port,
    });
  }

  onModuleDestroy() {
    this.redisClient.disconnect();
  }

  getClient(): Redis {
    return this.redisClient;
  }

  /**
   * Stores a key/value pair in Redis.
   *
   * @param key - The key under which the value will be stored.
   * @param value - The string value to store.
   * @param ttlSeconds - Optional time‑to‑live in seconds. If provided, the key
   *   will expire after the specified duration.
   * @returns A promise that resolves when the operation completes.
   */
  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    if (ttlSeconds) {
      await this.redisClient.set(key, value, 'EX', ttlSeconds);
    } else {
      await this.redisClient.set(key, value);
    }
  }

  /**
   * Retrieves the value for a given key.
   *
   * @param key - The key to look up.
   * @returns The stored string value or `null` if the key does not exist.
   */
  async get(key: string): Promise<string | null> {
    return this.redisClient.get(key);
  }

  /**
   * Deletes a key from Redis.
   *
   * @param key - The key to delete.
   * @returns The number of keys that were removed (0 or 1).
   */
  async del(key: string): Promise<number> {
    return this.redisClient.del(key);
  }
}
