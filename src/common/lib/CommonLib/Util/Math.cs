using System;

namespace CommonLib.Util.Math
{
    public static class GMath
    {
        private static readonly int[] PRIMES = new int[] { 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67};

        public static float Clamp(float min, float max, float val)
        {
            return val < min ? min : val > max ? max : val;
        }
        // Calculates the ::ref::Lerp parameter between of two values.
        public static float InverseLerp(float a, float b, float value)
        {
            if (a != b)
                return Clamp(0, 1, (value - a) / (b - a));
            else
                return 0.0f;
        }

        public static int ComputeHash(params int[] numbers)
        {
            var cnt = 0;
            var hash = PRIMES[cnt++];

            foreach (var i in numbers)
            {
                hash = hash * PRIMES[cnt++ % PRIMES.Length] + i;
            }

            return hash;
        }
    }

    public struct Vec2u
    {
        public static readonly ushort INVALID_AXIS = UInt16.MaxValue;

        public static readonly Vec2u ZERO = new Vec2u(0, 0);
        public static readonly Vec2u INVALID = new Vec2u(INVALID_AXIS, INVALID_AXIS);

        public ushort x;
        public ushort y;

        public Vec2u(int x, int y)
        {
            this.x = (ushort)x;
            this.y = (ushort)y;
        }

        public bool IsValid()
        {
            return x != INVALID_AXIS && y != INVALID_AXIS;
        }

        public bool IsOnBounds(int boundX, int boundY)
        {
            return x < boundX && y < boundY;
        }

        public float Magnitude()
        {
            return (float)System.Math.Sqrt(x * x + y * y);
        }

        public Vec2f Normalize()
        {
            var mag = Magnitude();
            return new Vec2f(x / mag, y / mag);
        }

        public override bool Equals(object o)
        {
            if (o == null || !(o is Vec2u))
                return false;

            return this == (Vec2u)o;
        }

        public bool Equals(Vec2u v)
        {
            return (x == v.x) && (y == v.y);
        }

        public override int GetHashCode()
        {
            return (x ^ 7) ^ (y ^ 13);
        }

        public static bool operator ==(Vec2u lhs, Vec2u rhs)
        {
            return lhs.x == rhs.x && lhs.y == rhs.y;
        }

        public static bool operator !=(Vec2u lhs, Vec2u rhs)
        {
            return !(lhs == rhs);
        }

        public static Vec2u operator -(Vec2u lhs, Vec2u rhs)
        {
            return new Vec2u(lhs.x - rhs.x, lhs.y - rhs.y);
        }

        public static Vec2u operator +(Vec2u lhs, Vec2u rhs)
        {
            return new Vec2u(lhs.x + rhs.x, lhs.y + rhs.y);
        }

        public static Vec2u operator *(Vec2u v, int i)
        {
            return new Vec2u(v.x * i, v.y * i);
        }

        public override string ToString()
        {
            return "[" + x + "," + y + "]";
        }

        public static implicit operator Vec2u(Vec2f other)
        {
            return new Vec2u((int)other.x, (int)other.y);
        }

        public static implicit operator Vec2u(Vec2 other)
        {
            return new Vec2u((int)other.x, (int)other.y);
        }
    }

    [Serializable]
    public struct Vec2 : IComparable<Vec2>
    {
        public static readonly short INVALID_AXIS = Int16.MaxValue;

        public static readonly Vec2 ZERO = new Vec2(0, 0);
        public static readonly Vec2 INVALID = new Vec2(INVALID_AXIS, INVALID_AXIS);

        public static readonly Vec2 UP = new Vec2(0, 1);
        public static readonly Vec2 RIGHT = new Vec2(1, 0);
        public static readonly Vec2 DOWN = new Vec2(0, -1);
        public static readonly Vec2 LEFT = new Vec2(-1, 0);

        public static readonly Vec2[] ALL_DIRS = new Vec2[] { UP, RIGHT, DOWN, LEFT };
        public static readonly Vec2[][] RND_DIRS = new Vec2[][]
        {
            new Vec2[]{ UP, RIGHT, DOWN, LEFT },
            new Vec2[]{ LEFT, UP, RIGHT, DOWN },
            new Vec2[]{ RIGHT, DOWN, LEFT, UP },
            new Vec2[]{ DOWN, LEFT, UP, RIGHT },
        };

        public short x;
        public short y;

        public Vec2(int x, int y)
        {
            this.x = (short)x;
            this.y = (short)y;
        }

        public bool IsValid()
        {
            return x != INVALID_AXIS && y != INVALID_AXIS;
        }

        public bool IsOnBounds(int boundX, int boundY)
        {
            return x < boundX && y < boundY;
        }

        public float Magnitude()
        {
            return (float)System.Math.Sqrt(x * x + y * y);
        }

        public Vec2f Normalize()
        {
            var mag = Magnitude();
            return new Vec2f(x / mag, y / mag);
        }

        public override bool Equals(object o)
        {
            if (o == null || !(o is Vec2))
                return false;

            return this == (Vec2)o;
        }

        public bool Equals(Vec2 v)
        {
            return (x == v.x) && (y == v.y);
        }

        public override int GetHashCode()
        {
            return GMath.ComputeHash(x, y);
        }

        public int Distance(Vec2 other)
        {
            var distance = this - other;
            return (int)distance.Magnitude();
        }
        public static bool operator ==(Vec2 lhs, Vec2 rhs)
        {
            return lhs.x == rhs.x && lhs.y == rhs.y;
        }

        public static bool operator !=(Vec2 lhs, Vec2 rhs)
        {
            return !(lhs == rhs);
        }

        public static Vec2 operator -(Vec2 lhs, Vec2 rhs)
        {
            return new Vec2(lhs.x - rhs.x, lhs.y - rhs.y);
        }

        public static Vec2 operator +(Vec2 lhs, Vec2 rhs)
        {
            return new Vec2(lhs.x + rhs.x, lhs.y + rhs.y);
        }

        public static Vec2 operator /(Vec2 lhs, int rhs)
        {
            return new Vec2(lhs.x / rhs, lhs.y / rhs);
        }

        public static Vec2 operator *(Vec2 lhs, int rhs)
        {
            return new Vec2(lhs.x * rhs, lhs.y * rhs);
        }

        public override string ToString()
        {
            return "[" + x + "," + y + "]";
        }

        public int CompareTo(Vec2 other)
        {
            return GetHashCode().CompareTo(other.GetHashCode());
        }

        public static implicit operator Vec2(Vec2f other)
        {
            return new Vec2((short)other.x, (short)other.y);
        }

        public static implicit operator Vec2(Vec2u other)
        {
            return new Vec2(other.x, other.y);
        }
    }

    public struct Vec2f
    {
        public static readonly float EPSILON = 0.00001f;
        public static readonly float INVALID_AXIS = float.NaN;

        public static readonly Vec2f ZERO = new Vec2f(0, 0);
        public static readonly Vec2f INVALID = new Vec2f(INVALID_AXIS, INVALID_AXIS);

        public float x;
        public float y;

        public Vec2f(float x, float y)
        {
            this.x = x;
            this.y = y;
        }

        public bool IsValid()
        {
            return !float.IsNaN(x) && !float.IsNaN(y);
        }

        public bool IsOnBounds(float boundX, float boundY)
        {
            return x < boundX && y < boundY;
        }

        public float Magnitude()
        {
            return (float)System.Math.Sqrt(x * x + y * y);
        }

        public void Normalize()
        {
            var mag = Magnitude();
            x /= mag;
            y /= mag;
        }

        public void Reset()
        {
            x = 0;
            y = 0;
        }

        public void Clamp(float min, float max)
        {
            x = GMath.Clamp(min, max, x);
            y = GMath.Clamp(min, max, y);
        }

        public void Clamp(Vec2f min, Vec2f max)
        {
            x = GMath.Clamp(min.x, max.x, x);
            y = GMath.Clamp(min.y, max.y, y);
        }

        public static Vec2f operator +(Vec2f lhs, int rhs)
        {
            return new Vec2f(lhs.x + rhs, lhs.y + rhs);
        }

        public static bool operator ==(Vec2f lhs, Vec2f rhs)
        {
            return System.Math.Abs(lhs.x - rhs.x) < EPSILON && System.Math.Abs(lhs.y - rhs.y) < EPSILON;
        }

        public static bool operator !=(Vec2f lhs, Vec2f rhs)
        {
            return !(lhs == rhs);
        }

        public static Vec2f operator -(Vec2f lhs, Vec2f rhs)
        {
            return new Vec2f(lhs.x - rhs.x, lhs.y - rhs.y);
        }

        public static Vec2f operator +(Vec2f lhs, Vec2f rhs)
        {
            return new Vec2f(lhs.x + rhs.x, lhs.y + rhs.y);
        }

        public static Vec2f operator +(Vec2f lhs, float rhs)
        {
            return new Vec2f(lhs.x + rhs, lhs.y + rhs);
        }

        public static Vec2f operator -(Vec2f lhs, float rhs)
        {
            return new Vec2f(lhs.x - rhs, lhs.y - rhs);
        }

        public static Vec2f operator *(Vec2f lhs, float rhs)
        {
            return new Vec2f(lhs.x * rhs, lhs.y * rhs);
        }

        public override bool Equals(object o)
        {
            if (o == null || !(o is Vec2f))
                return false;

            return this == (Vec2f)o;
        }

        public bool Equals(Vec2f v)
        {
            return (x == v.x) && (y == v.y);
        }
        public override int GetHashCode()
        {
            return (int)(System.Math.Sqrt((int)(x * 1000) ^ 7)) ^ (int)(System.Math.Sqrt((int)(y * 1000) ^ 13));
        }

        public override string ToString()
        {
            return "[" + x + "," + y + "]";
        }

        public static implicit operator Vec2f(Vec2 other)
        {
            return new Vec2f(other.x, other.y);
        }

        public static implicit operator Vec2f(Vec2u other)
        {
            return new Vec2f(other.x, other.y);
        }
    }

    public struct Rang2
    {
        public static readonly Rang2 INVALID = new Rang2(Vec2u.INVALID, Vec2u.INVALID);

        public Vec2u beg;
        public Vec2u end;

        public Rang2(Vec2u beg, Vec2u end)
        {
            this.beg = beg;
            this.end = end;
        }

        public bool IsValid()
        {
            return beg.IsValid() && end.IsValid();
        }

        public bool Contains(Vec2u point)
        {
            return beg.x > point.x && beg.y > point.y && end.x < point.y && end.y < point.y;
        }
    }

    public struct Rect2i
    {
        public static readonly Rect2i INVALID = new Rect2i(Vec2.INVALID, Vec2.INVALID);

        public Vec2 start;
        public Vec2 end;
        public Vec2 center;

        public Rect2i(int x, int y, int width, int height) : this(new Vec2(x, y), new Vec2(x + width, y + height))
        {
        }

        public Rect2i(Vec2 start, Vec2 end)
        {
            this.start = start;
            this.end = end;
            this.center = start + (end - start) / 2;
        }

        public bool IsValid()
        {
            return start.IsValid() || start.IsValid();
        }

        public bool Contains(Vec2 point)
        {
            return start.x <= point.x && start.y <= point.y && end.x >= point.y && end.y >= point.y;
        }

        public Rect2i Expand(int scale)
        {
            return new Rect2i(start.x - scale, start.y - scale, end.x - start.x + scale, end.y - start.y + scale);
        }

        public int Width()
        {
            return end.x - start.x;
        }

        public int Height()
        {
            return end.y - start.y;
        }
    }



}
