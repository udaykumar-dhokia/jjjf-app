import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { SendEmailPayload } from './email.service.js';

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
    } as any);

    (this.transporter as any).options.host = this.configService.get<string>('SMTP_HOST') || 'smtp.gmail.com';
    (this.transporter as any).options.family = 4;

  }

  /**
   * Processes an email job from the BullMQ queue.
   *
   * @param job - The BullMQ job containing the email payload.
   * @returns An object indicating success and the message ID when the email
   *   was sent. If the send fails, the error is logged and re‑thrown so that
   *   BullMQ can handle retries according to the job options defined in
   *   {@link EmailService.sendEmailQueue}.
   */
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
