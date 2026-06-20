import { Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

export interface SendEmailPayload {
  to: string;
  subject: string;
  text?: string;
  html?: string;
}

@Injectable()
export class EmailService {
  constructor(@InjectQueue('email') private readonly emailQueue: Queue) {}

  /**
   * Adds an email sending job to the BullMQ queue.
   *
   * @param payload - The email details including recipient, subject and optional
   *   plain text or HTML body.
   * @returns A promise that resolves when the job has been added to the queue.
   *   The job will be retried up to 3 times with exponential back‑off starting
   *   at 1 second. Completed jobs are removed from the queue, failed jobs are
   *   retained for inspection.
   */
  async sendEmailQueue(payload: SendEmailPayload) {
    await this.emailQueue.add('send-email-job', payload, {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 1000,
      },
      removeOnComplete: true,
      removeOnFail: false,
    });
  }

  /**
   * Sends a one‑time password (OTP) email to the specified recipient.
   *
   * @param to - Recipient email address.
   * @param otp - The one‑time password to include in the email body.
   * @returns A promise that resolves when the OTP email has been queued.
   */
  async sendOtpEmail(to: string, otp: string) {
    const subject = 'Your Verification OTP - Jalore Jain Sangh';
    const text = `Hello,\n\nYour One-Time Password (OTP) for Jalore Jain Sangh is: ${otp}\n\nThis OTP is valid for 5 minutes. Do not share this code with anyone.\n\nRegards,\nJalore Jain Sangh Team`;

    await this.sendEmailQueue({ to, subject, text });
  }
}
