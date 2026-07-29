import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Client } from './client.entity';

@Injectable()
export class ClientRepository {
  constructor(
    @InjectRepository(Client)
    private readonly repo: Repository<Client>,
  ) {}

  findByCode(code: string): Promise<Client | null> {
    return this.repo.findOneBy({ code });
  }

  findById(id: string): Promise<Client | null> {
    return this.repo.findOneBy({ id });
  }

  create(partial?: Partial<Client>): Client {
    return partial ? this.repo.create(partial) : this.repo.create();
  }

  save(client: Client): Promise<Client> {
    return this.repo.save(client);
  }
}
