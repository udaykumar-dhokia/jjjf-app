import { IsString, IsArray, ArrayMaxSize, IsOptional, IsMongoId } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateNewsDto {
  @ApiProperty({ example: 'Community Event' })
  @IsString()
  title!: string;

  @ApiProperty({ example: 'This is a description.' })
  @IsString()
  description!: string;

  @ApiProperty({ example: ['url1', 'url2'], required: false })
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(3, { message: 'A maximum of 3 images are allowed' })
  @IsOptional()
  images?: string[];

  @ApiProperty({ example: '60d5ecb8b392d70015340123' })
  @IsMongoId()
  userId!: string;

  @ApiProperty({ example: 'Udaykumar' })
  @IsString()
  userName!: string;
}
