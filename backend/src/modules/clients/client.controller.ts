import { Body, Controller, Post, Get, Param, NotFoundException } from '@nestjs/common';
import { ClientService } from './client.service';
import { RegisterClientDto } from './dto/register-client.dto';

@Controller('api/v1/clients')
export class ClientController {
  constructor(private readonly clientService: ClientService) {}

  @Post('register')
  async register(@Body() dto: RegisterClientDto) {
    const client = await this.clientService.registerClient(
      dto.code,
      dto.fcm_token,
    );

    return {
      id: client.id,
      code: client.code,
      createdAt: client.createdAt,
    };
  }

  @Get(':code')
  async getClient(@Param('code') code: string) {
    const client = await this.clientService.findByCode(code);
    if (!client) {
      throw new NotFoundException('Client not found');
    }
    return client;
  }
}
