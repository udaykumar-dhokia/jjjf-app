import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { google } from 'googleapis';
import { SendEmailPayload } from './email.service.js';

@Processor('email')
export class EmailProcessor extends WorkerHost {
  private readonly logger = new Logger(EmailProcessor.name);
  private oauth2Client: any;

  constructor(private readonly configService: ConfigService) {
    super();

    const clientId = this.configService.get<string>('GMAIL_CLIENT_ID');
    const clientSecret = this.configService.get<string>('GMAIL_CLIENT_SECRET');
    const refreshToken = this.configService.get<string>('GMAIL_REFRESH_TOKEN');

    this.oauth2Client = new google.auth.OAuth2(
      clientId,
      clientSecret,
      'https://developers.google.com/oauthplayground'
    );

    if (refreshToken) {
      this.oauth2Client.setCredentials({
        refresh_token: refreshToken
      });
    } else {
      this.logger.warn('GMAIL_REFRESH_TOKEN is not set. Emails will fail to send if using Gmail API.');
    }
  }

  /**
   * Helper function to construct an RFC 2822 base64url encoded email string.
   */
  private createMessage(to: string, from: string, subject: string, text?: string, html?: string): string {
    const boundary = '==_mime_boundary_';
    let message = [
      `To: ${to}`,
      `From: ${from}`,
      `Subject: ${subject}`,
      `MIME-Version: 1.0`,
      `Content-Type: multipart/alternative; boundary="${boundary}"`,
      '',
    ];

    if (text) {
      message.push(`--${boundary}`);
      message.push(`Content-Type: text/plain; charset="UTF-8"`);
      message.push('');
      message.push(text);
      message.push('');
    }

    if (html) {
      message.push(`--${boundary}`);
      message.push(`Content-Type: text/html; charset="UTF-8"`);
      message.push('');
      message.push(html);
      message.push('');
    }

    message.push(`--${boundary}--`);

    return Buffer.from(message.join('\n'))
      .toString('base64')
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  }

  /**
   * Processes an email job from the BullMQ queue using Gmail API.
   */
  async process(job: Job<SendEmailPayload, any, string>): Promise<any> {
    this.logger.log(`Processing email job ${job.id} of type ${job.name}...`);
    this.logger.log(`Sending email to ${job.data.to} with subject "${job.data.subject}"`);

    try {
      const fromEmail = this.configService.get<string>('SMTP_USER') || 'noreply@example.com';
      const from = `"Jalore Jain Sangh" <${fromEmail}>`;

      const rawMessage = this.createMessage(
        job.data.to,
        from,
        job.data.subject,
        job.data.text,
        job.data.html
      );

      const gmail = google.gmail({ version: 'v1', auth: this.oauth2Client });

      const res = await gmail.users.messages.send({
        userId: 'me',
        requestBody: {
          raw: rawMessage,
        },
      });

      this.logger.log(`Email successfully sent to ${job.data.to}. Message ID: ${res.data?.id}`);
      return { success: true, messageId: res.data?.id };
    } catch (error: any) {
      this.logger.error(`Failed to send email to ${job.data.to}: ${error.message}`);
      throw error;
    }
  }
}

