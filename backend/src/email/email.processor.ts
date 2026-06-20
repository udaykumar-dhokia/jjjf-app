import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { SendEmailPayload } from './email.service';

@Processor('email')
export class EmailProcessor extends WorkerHost {
  private readonly logger = new Logger(EmailProcessor.name);
  private transporter: nodemailer.Transporter;

  constructor(private readonly configService: ConfigService) {
    super();
    this.transporter = nodemailer.createTransport({
      host: this.configService.get<string>('SMTP_HOST') || 'smtp.gmail.com',
      port: this.configService.get<number>('SMTP_PORT') || 587,
      secure: this.configService.get<number>('SMTP_PORT') === 465,
      auth: {
        user: this.configService.get<string>('SMTP_USER'),
        pass: this.configService.get<string>('SMTP_PASS'),
      },
    });
  }

  async process(job: Job<SendEmailPayload, any, string>): Promise<any> {
    this.logger.log(`Processing email job ${job.id} of type ${job.name}...`);
    this.logger.log(`Sending email to ${job.data.to} with subject "${job.data.subject}"`);
    
    try {
      const info = await this.transporter.sendMail({
        from: `"Jalore Jain Sangh" <${this.configService.get<string>('SMTP_USER')}>`,
        to: job.data.to,
        subject: job.data.subject,
        text: job.data.text,
        html: job.data.html,
      });
      
      this.logger.log(`Email successfully sent to ${job.data.to}. Message ID: ${info.messageId}`);
      return { success: true, messageId: info.messageId };
    } catch (error: any) {
      this.logger.error(`Failed to send email to ${job.data.to}: ${error.message}`);
      throw error;
    }
  }
}
