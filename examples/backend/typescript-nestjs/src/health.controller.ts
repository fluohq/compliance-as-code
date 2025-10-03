import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get('health')
  getHealth() {
    return {
      status: 'healthy',
      version: '1.0.0',
      compliance: {
        frameworks: ['GDPR', 'SOC2'],
        controls: ['Art.15', 'Art.17', 'Art.5(1)(f)', 'CC6.1'],
      },
    };
  }
}
