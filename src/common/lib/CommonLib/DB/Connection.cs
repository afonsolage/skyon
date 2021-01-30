#if _SERVER

using Npgsql;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.DB
{
    public static class ConnectionFactory
    {
        private static readonly Dictionary<string, string> _connStringMap = new Dictionary<string, string>();

        public static void LoadConfigFile(string path)
        {
            var lines = File.ReadAllLines(path);

            foreach(var line in lines)
            {
                var strs = line.Split('|');

                if (strs.Length != 2)
                    continue;

                AddConnectionString(strs[0], strs[1]);
            }
        }

        public static void AddConnectionString(string name, string data)
        {
            _connStringMap[name] = data;
        }

        internal static NpgsqlConnection GetConnection(string name)
        {
            var connectionString = _connStringMap[name];
            return new NpgsqlConnection(connectionString);
        }

        [ThreadStatic]
        private static byte[] _temp;
        public static byte[] GetByteArray(this NpgsqlDataReader reader, int ordinal)
        {
            if (!reader.IsOnRow)
                return null;

            if (_temp == null)
                 _temp = new byte[1024 * 1024]; //1MB

            var readLen = reader.GetBytes(ordinal, 0, _temp, 0, _temp.Length);
            var res = new byte[readLen];
            Array.Copy(_temp, res, readLen);
            return res;
        }
    }

    public class DBConnection : IDisposable
    {
        private NpgsqlConnection _connection;

        public DBConnection(string databaseName)
        {
            _connection = ConnectionFactory.GetConnection(databaseName);
            _connection.Open();
        }

        public int Execute(string command, params object[] parameters)
        {
            var cmd = new NpgsqlCommand(command, _connection);

            int paramIdx = 1;
            foreach(object param in parameters)
            {
                cmd.Parameters.AddWithValue("@p" + paramIdx++, param);
            }

            return cmd.ExecuteNonQuery();
        }

        public NpgsqlDataReader Query(string command, params object[] parameters)
        {
            var cmd = new NpgsqlCommand(command, _connection);

            int paramIdx = 1;
            foreach (object param in parameters)
            {
                cmd.Parameters.AddWithValue("@p" + paramIdx++, param);
            }

            return cmd.ExecuteReader();
        }

        public void Dispose()
        {
            if (_connection.State == ConnectionState.Open)
                _connection.Close();
        }
    }
}

#endif