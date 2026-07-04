import { Injectable, Inject } from '@nestjs/common';
import { v2 as cloudinary, UploadApiErrorResponse, UploadApiResponse } from 'cloudinary';
import * as streamifier from 'streamifier';
import 'multer';

/**
 * Service for uploading images to Cloudinary.
 *
 * Provides a method to upload an image file and returns the Cloudinary response.
 */
@Injectable()
export class CloudinaryService {
  constructor(@Inject('Cloudinary') private cloudinaryConfig: any) {}

  /**
   * Uploads an image file to Cloudinary.
   *
   * @param file - The image file to be uploaded, provided by Multer.
   * @returns A promise that resolves with the Cloudinary upload response
   *          or rejects with an error response.
   */
  uploadImage(
    file: Express.Multer.File,
  ): Promise<UploadApiResponse | UploadApiErrorResponse> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        (error, result) => {
          if (error) return reject(error);
          if (!result) return reject(new Error('Upload result is undefined'));
          resolve(result);
        },
      );
      streamifier.createReadStream(file.buffer).pipe(uploadStream);
    });
  }

  /**
   * Deletes an image from Cloudinary.
   *
   * @param publicId - The public identifier of the image to delete.
   * @returns A promise that resolves with the Cloudinary deletion result
   *          or rejects with an error if the operation fails.
   */
  async deleteImage(publicId: string): Promise<any> {
    return new Promise((resolve, reject) => {
      cloudinary.uploader.destroy(publicId, (error, result) => {
        if (error) return reject(error);
        resolve(result);
      });
    });
  }
}
