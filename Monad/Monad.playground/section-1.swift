



// MONAD protocol

protocol Monad {
    typealias A
    typealias U
    class func ret(value: A) -> Self
    func bind<M : Monad>(wrap: A -> M) -> M
}

operator infix >>= { associativity left }
operator infix >> { associativity left }

func >>= <MA : Monad, MB : Monad where MA.U == MB.U>(lhs: MA, rhs: MA.A -> MB) -> MB {
    return lhs.bind(rhs)
}
func >> <MA : Monad, MB : Monad where MA.U == MB.U>(lhs: MA, rhs: MB) -> MB {
    return lhs.bind { _ in rhs }
}

// FUNCTOR protocol

protocol Functor {
    typealias A
    typealias FB
    func fmap<B>(transform: (A) -> B) -> FB
}



// MAYBE conforms MONAD protocol

enum Maybe<T> {
    case Nothing
    case Just(T);
    func fromJust() -> T {
        switch self {
        case .Just(let a): return a;
        case .Nothing: return nil!; // error
        }
    }
}

extension Maybe : Monad, Functor {
    typealias A = T
    typealias U = Maybe<()>
    
    static func ret(value: A) -> Maybe<A> {
        return .Just(value);
    }
    
    func bind<M : Monad>(wrap: A -> M) -> M {
        switch self {
        case .Just(let a): return wrap(a);
        case .Nothing: return Maybe.Nothing as M;
        }
    }
    
    func fmap<B>(transform: (A) -> B) -> Maybe<B> {
        switch self {
        case .Just(let a): return Maybe<B>.Just(transform(a));
        case .Nothing: return Maybe<B>.Nothing;
        }
    }
}


// OPTIONAL conforms MONAD protocol

extension Optional : Monad, Functor {
    typealias A = T
    typealias U = Optional<()>
    
    static func ret(value: A) -> Optional<A> {
        return .Some(value);
    }
    
    func bind<M : Monad>(wrap: A -> M) -> M {
        switch self {
        case .Some(let a): return wrap(a);
        case .None: return Optional.None as M;
        }
    }
    
    func fmap<B>(transform: (A) -> B) -> Optional<B> {
        switch self {
        case .Some(let a): return Optional<B>.Some(transform(a));
        case .None: return Optional<B>.None;
        }
    }
}




// examples monads

// Modify value within Maybe
let example1 = Maybe.ret(5) >> Maybe.ret(6);
let example2 = Maybe.ret(5) >>= { x in Maybe.ret(x+1) };

example1
example2

// Change type of value within Maybe
let example3 = Maybe.ret(5) >> Maybe.ret(true);
let example4 = Maybe.ret(5) >>= { _ in Maybe.ret(true) };

example3
example4

// As expected, you can't change the Monad Type
let example5 = Maybe.ret(5) >> Optional.ret(5)
let example6 = Maybe.ret(5) >>= { _ in Optional.ret(true) }


// examples fmap

let example7 = Optional<Bool>.Some(true).fmap({x in !x})
let example8 = Maybe<Int>.Just(7).fmap({ x in x+1 }).fmap({x in x==8})
let example9 = Maybe<Int>.Just(7).fmap({ x in true });

example7!
example8.fromJust()
example9.fromJust()
