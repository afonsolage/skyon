using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Util
{
    public class CompressionHelper
    {
        public static byte[] CompressLossy2Precision(float[] data)
        {
            var res = new byte[data.Length];
            for (var i = 0; i < data.Length; i++)
            {
                res[i] = (byte)(data[i] * 100);
            }
            return res;
        }

        public static float[] DecompressLossy2Precision(byte[] data)
        {
            var res = new float[data.Length];
            for (var i = 0; i < data.Length; i++)
            {
                res[i] = data[i] / 100.0f;
            }
            return res;
        }

        public static ushort[] CompressWithLossy4Precision(float[] data)
        {
            var res = new ushort[data.Length];
            for(var i = 0; i < data.Length; i++)
            {
                res[i] = (ushort)(data[i] * 10000);
            }
            return res;
        }

        public static byte[] Compress(Enum[] data, int size = 4)
        {
            var buffer = new byte[data.Length * size];
            Buffer.BlockCopy(data, 0, buffer, 0, buffer.Length);
            return Compress(buffer);
        }

        public static byte[] Compress(float[] data)
        {
            var buffer = new byte[data.Length * 4];
            Buffer.BlockCopy(data, 0, buffer, 0, buffer.Length);
            return Compress(buffer);
        }

        public static byte[] Compress(ushort[] data)
        {
            var buffer = new byte[data.Length * 2];
            Buffer.BlockCopy(data, 0, buffer, 0, buffer.Length);
            return Compress(buffer);
        }

        public static byte[] Compress(byte[] data)
        {
            if (data == null)
                return null;

            using (var outputStream = new MemoryStream())
            using (var zipStream = new GZipStream(outputStream, CompressionLevel.Optimal))
            {
                zipStream.Write(data, 0, data.Length);
                return outputStream.ToArray();
            }
        }

        public static byte[] Decompress(byte[] data)
        {
            if (data == null)
                return null;

            using (var outputStream = new MemoryStream())
            using (var zipStream = new DeflateStream(outputStream, CompressionLevel.Optimal))
            {
                zipStream.Write(data, 0, data.Length);
                return outputStream.ToArray();
            }
        }
    }
}
