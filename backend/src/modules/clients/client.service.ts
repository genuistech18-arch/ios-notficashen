import { Injectable, NotFoundException } from '@nestjs/common';
import { ClientRepository } from './client.repository';
import { Client } from './client.entity';

@Injectable()
export class ClientService {
  constructor(private readonly clients: ClientRepository) {}

  async registerClient(code: string, fcmToken: string): Promise<Client> {
    let client = await this.clients.findByCode(code);
    if (!client) {
      client = this.clients.create({
        code,
        fcmToken,
      });
    } else {
      client.fcmToken = fcmToken;
    }
    return this.clients.save(client);
  }

  findByCode(code: string): Promise<Client | null> {
    return this.clients.findByCode(code);
  }

  async invalidateToken(client: Client): Promise<void> {
    client.fcmToken = null;
    await this.clients.save(client);
  }
}
