using ProtoBuf;
using System;
using System.IO;

namespace Messages.Common
{
    public interface IMessage
    {
        ushort MsgCode { get; }
    }

    public class RawMessage
    {
        public ushort MsgCode;
        private byte[] _buffer;

        public RawMessage(byte[] buffer)
        {
            MsgCode = MessageSerializer.Deserialize<IMessage>(buffer).MsgCode;
            _buffer = buffer;
        }

        public RawMessage(RawMessage other)
        {
            MsgCode = MessageSerializer.Deserialize<IMessage>(other._buffer).MsgCode;
            _buffer = other._buffer;
        }

        public T To<T>() where T : IMessage
        {
            return MessageSerializer.Deserialize<T>(_buffer);
        }
    }

    public class MessageSerializer
    {
        // 1 MB
        private static readonly uint MAX_MESSAGE_SIZE = 1048576;

        [ThreadStatic]
        private static byte[] buffer;

        public static byte[] Serialize<T>(T msg) where T : IMessage
        {
            if (buffer == null)
            {
                buffer = new byte[MAX_MESSAGE_SIZE];
            }

            byte[] result;

            using (var stream = new MemoryStream(buffer))
            {
                Serializer.Serialize(stream, msg);

                result = new byte[stream.Position];
                Array.Copy(buffer, result, result.Length);
            }

            return result;
        }

        public static T Deserialize<T>(byte[] buffer) where T : IMessage
        {
            T result;

            using (var stream = new MemoryStream(buffer))
            {
                result = Serializer.Deserialize<T>(stream);
            }

            return result;
        }
    }
}
