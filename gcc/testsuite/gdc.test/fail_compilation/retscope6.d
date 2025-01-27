/*
REQUIRED_ARGS: -preview=dip1000
*/

/*
TEST_OUTPUT:
---
fail_compilation/retscope6.d(6007): Error: copying `& i` into allocated memory escapes a reference to local variable `i`
---
*/

#line 6000

// https://issues.dlang.org/show_bug.cgi?id=17795

int* test() @safe
{
    int i;
    int*[][] arr = new int*[][](1);
    arr[0] ~= &i;
    return arr[0][0];
}

/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(7034): Error: address of variable `i` assigned to `s` with longer lifetime
fail_compilation/retscope6.d(7035): Error: address of variable `i` assigned to `s` with longer lifetime
fail_compilation/retscope6.d(7025): Error: scope variable `_param_2` assigned to `t` with longer lifetime
fail_compilation/retscope6.d(7037): Error: template instance `retscope6.S.emplace4!(int*)` error instantiating
fail_compilation/retscope6.d(7037): Error: address of variable `i` assigned to `s` with longer lifetime
---
*/

#line 7000

alias T = int*;

struct S
{
    T payload;

    static void emplace(Args...)(ref S s, Args args) @safe
    {
        s.payload = args[0];
    }

    void emplace2(Args...)(Args args) @safe
    {
        payload = args[0];
    }

    static void emplace3(Args...)(S s, Args args) @safe
    {
        s.payload = args[0];
    }

    static void emplace4(Args...)(scope ref S s, scope out S t, scope Args args) @safe
    {
        s.payload = args[0];
        t.payload = args[0];
    }

}

void foo() @safe
{
    S s;
    int i;
    s.emplace(s, &i);
    s.emplace2(&i);
    s.emplace3(s, &i);
    s.emplace4(s, s, &i);
}


/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(8016): Error: address of variable `i` assigned to `p` with longer lifetime
fail_compilation/retscope6.d(8031): Error: reference to local variable `i` assigned to non-scope parameter `p` calling retscope6.betty!().betty
fail_compilation/retscope6.d(8031): Error: reference to local variable `j` assigned to non-scope parameter `q` calling retscope6.betty!().betty
fail_compilation/retscope6.d(8048): Error: reference to local variable `j` assigned to non-scope parameter `q` calling retscope6.archie!().archie
---
*/

// https://issues.dlang.org/show_bug.cgi?id=19035

#line 8000
@safe
{

void escape(int*);

/**********************/

void frank()(ref scope int* p, int* s)
{
    p = s;  // should error here
}

void testfrankly()
{
    int* p;
    int i;
    frank(p, &i);
}

/**********************/

void betty()(int* p, int* q)
{
     p = q;
     escape(p);
}

void testbetty()
{
    int i;
    int j;
    betty(&i, &j); // should error on i and j
}

/**********************/

void archie()(int* p, int* q, int* r)
{
     p = q;
     r = p;
     escape(q);
}

void testarchie()
{
    int i;
    int j;
    int k;
    archie(&i, &j, &k); // should error on j
}

}

/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(9022): Error: returning `fred(& i)` escapes a reference to local variable `i`
---
*/

#line 9000

@safe:

alias T9 = S9!(); struct S9()
{
     this(int* q)
     {
        this.p = q;
     }

     int* p;
}

auto fred(int* r)
{
    return T9(r);
}

T9 testfred()
{
    int i;
    auto j = fred(&i); // ok
    return fred(&i);   // error
}

/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(10003): Error: scope variable `values` assigned to non-scope parameter `values` calling retscope6.escape
---
*/

#line 10000

void variadicCaller(int[] values...)
{
    escape(values);
}

void escape(int[] values) {}

/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(11004): Error: address of variable `buffer` assigned to `secret` with longer lifetime
---
*/

#line 11000

void hmac(scope ubyte[] secret)
{
    ubyte[10] buffer;
    secret = buffer[];
}

/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(12011): Error: reference to local variable `x` assigned to non-scope parameter `r` calling retscope6.escape_m_20150
fail_compilation/retscope6.d(12022): Error: reference to local variable `x` assigned to non-scope parameter `r` calling retscope6.escape_c_20150
---
*/

#line 12000

// https://issues.dlang.org/show_bug.cgi?id=20150

int* escape_m_20150(int* r) @safe pure
{
    return r;
}

int* f_m_20150() @safe
{
    int x = 42;
    return escape_m_20150(&x);
}

const(int)* escape_c_20150(const int* r) @safe pure
{
    return r;
}

const(int)* f_c_20150() @safe
{
    int x = 42;
    return escape_c_20150(&x);
}

/* TEST_OUTPUT:
---
fail_compilation/retscope6.d(13010): Error: reference to local variable `str` assigned to non-scope parameter `x` calling retscope6.f_throw
---
*/

#line 13000
// https://issues.dlang.org/show_bug.cgi?id=22221

void f_throw(string x) @safe pure
{
    throw new Exception(x);
}

void escape_throw_20150() @safe
{
    immutable(char)[4] str;
    f_throw(str[]);
}
