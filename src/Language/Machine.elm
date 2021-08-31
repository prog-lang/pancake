module Language.Machine exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Language.Stack as Stack exposing (Stack)
import Language.World exposing (World(..))



-- RUNTIME


type alias Machine =
    -- State.
    { status : Result Error ()
    , world : World
    , code : Code
    , ip : Int

    -- Values.
    , labels : Dict String Int
    , names : Dict String Value
    , stack : Stack Value
    }


type alias Code =
    Array Instruction


type alias Instruction =
    { line : Int
    , world : World
    , value : Value
    }


init : Code -> Dict String Int -> Machine
init code labels =
    { status = Ok ()
    , world = Alpha
    , code = code
    , ip = 0
    , labels = labels
    , names = Dict.empty
    , stack = Stack.empty
    }


panic : Error -> Command
panic error machine =
    { machine | status = Err error }


push : Value -> Command
push value machine =
    { machine | stack = Stack.push value machine.stack }


skip : Command
skip machine =
    { machine | ip = machine.ip + 1 }



-- ERROR


type alias Error =
    String


combine : Error -> Error -> Error
combine e1 e2 =
    e1 ++ "\n|> " ++ e2



-- VALUE


type Value
    = Char Char
    | Int Int
    | List (List Value)
    | Id String
    | Command Command


toInt : Value -> Maybe Int
toInt value =
    case value of
        Int int ->
            Just int

        _ ->
            Nothing


toHtml : Value -> Html msg
toHtml value =
    case value of
        Char char ->
            "'" ++ String.fromChar char ++ "'" |> text

        Int int ->
            String.fromInt int |> text

        List _ ->
            text "< list >"

        Id id ->
            "{ " ++ id ++ " }" |> text

        Command _ ->
            "< command >" |> text



-- COMMAND


type alias Command =
    Machine -> Machine
