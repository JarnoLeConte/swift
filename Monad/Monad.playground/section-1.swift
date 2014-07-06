



// MONAD protocol

operator infix >>= { associativity left }
operator infix >> { associativity left }

protocol Monad {
    typealias A
    typealias M
    
    func bind<MB : Monad>(A -> MB) -> MB
    class func ret(value: A) -> Self
}

func >>= <MA : Monad, MB : Monad where MA.M == MB.M>(lhs: MA, rhs: MA.A -> MB) -> MB {
    return lhs.bind(rhs)
}

func >> <MA : Monad, MB : Monad where MA.M == MB.M>(lhs: MA, rhs: MB) -> MB {
    return lhs.bind { _ in rhs }
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

extension Maybe : Monad {
    typealias A = T
    typealias M = Maybe<()>
    
    func bind<MB : Monad>(f: A -> MB) -> MB {
        switch self {
        case .Just(let a): return f(a);
        case .Nothing: return Maybe.Nothing as MB;
        }
    }
    
    static func ret(value: A) -> Maybe<A> {
        return .Just(value);
    }
    
    
}


// OPTIONAL conforms MONAD protocol

extension Optional : Monad {
    typealias A = T
    typealias M = Optional<()>
    
    func bind<MB : Monad>(f: A -> MB) -> MB {
        switch self {
        case .Some(let a): return f(a);
        case .None: return Optional.None as MB;
        }
    }
    
    static func ret(value: A) -> Optional<A> {
        return .Some(value);
    }
}



// examples

// Modify value within Maybe
let example1 = Maybe.ret(5) >> Maybe.ret(6);
let example2 = Maybe.ret(5) >>= { x in Maybe.ret(x+1) };

// Change type of value within Maybe
let example3 = Maybe.ret(5) >> Maybe.ret(true);
let example4 = Maybe.ret(5) >>= { _ in Maybe.ret(true) };

// It is NOT allowed to change the monad type (Maybe to Optional),
// exactly what you should expect
//let example5 = Maybe.ret(5) >> Optional.ret(5);
//let example6 = Maybe.ret(5) >>= { _ in Optional.ret(true) };


example1.fromJust()
example2.fromJust()
example3.fromJust()
example4.fromJust()


