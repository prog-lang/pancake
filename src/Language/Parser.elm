module Language.Parser exposing
    ( Ast
    , AstLine
    , Citizen(..)
    , ErrorLine
    , Item(..)
    , ParseError
    , ParseResult
    , getLabel
    , isLabel
    , isNote
    , parse
    , toErrorLineNumbers
    )

import Language.World exposing (World(..))
import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , backtrackable
        , chompUntil
        , chompWhile
        , end
        , getChompedString
        , int
        , lineComment
        , oneOf
        , spaces
        , succeed
        , symbol
        )
import Result.Extra as ResultX
import Set exposing (Set)
import String.Extra exposing (nonEmpty)



-- PARSE RESULT


type alias ParseResult =
    Result ParseError Ast


type alias ParseError =
    List ErrorLine


toErrorLineNumbers : ParseError -> Set Int
toErrorLineNumbers =
    List.map (\{ number } -> number) >> Set.fromList


type alias ErrorLine =
    { number : Int
    , error : String
    }


type alias Ast =
    List AstLine


type alias AstLine =
    { number : Int
    , item : Citizen
    }


type Citizen
    = Citizen World Item Comment
    | Label String Comment
    | Note Comment


isLabel : Citizen -> Bool
isLabel citizen_ =
    case citizen_ of
        Label _ _ ->
            True

        _ ->
            False


getLabel : Citizen -> Maybe String
getLabel citizen_ =
    case citizen_ of
        Label l _ ->
            Just l

        _ ->
            Nothing


isNote : Citizen -> Bool
isNote citizen_ =
    case citizen_ of
        Note _ ->
            True

        _ ->
            False


type alias Comment =
    String


type Item
    = Int Int
    | Str String
    | Id String



-- PARSE


type alias Line =
    { number : Int, value : String }


parse : String -> ParseResult
parse source =
    let
        results : List (Result ErrorLine AstLine)
        results =
            source |> lines |> List.map parseLine
    in
    case ResultX.combine results of
        Ok ast ->
            Ok ast

        Err _ ->
            Err <| List.filterMap ResultX.error results


lines : String -> List Line
lines =
    let
        enumerate ls =
            List.map2
                (\num str -> String.trim str |> Line num)
                (List.range 1 <| List.length ls)
                ls

        notEmpty =
            List.filter (\{ value } -> value |> String.isEmpty |> not)
    in
    String.lines >> enumerate >> notEmpty


parseLine : Line -> Result ErrorLine AstLine
parseLine { number, value } =
    Parser.run citizen value
        |> ResultX.mapBoth
            (always <| ErrorLine number "failed to parse line")
            (AstLine number)



-- COMBINATORS


citizen : Parser Citizen
citizen =
    oneOf
        [ backtrackable <|
            succeed Note
                |. spaces
                |= comment
        , succeed identity
            |. spaces
            |= oneOf
                [ succeed Label
                    |. symbol "@"
                    |. spaces
                    |= label
                    |= comment
                , succeed (Citizen Omega)
                    |. symbol "#"
                    |= item
                    |= comment
                , succeed (Citizen Alpha)
                    |= item
                    |= comment
                ]
        ]


comment : Parser String
comment =
    succeed identity
        |. spaces
        |= oneOf
            [ lineComment ";" |> getChompedString
            , Parser.map (always "") end
            ]


label : Parser String
label =
    let
        isaLabel c =
            Char.isAlpha c || c == ' '
    in
    getChompedString <| chompWhile isaLabel


item : Parser Item
item =
    succeed identity
        |. spaces
        |= oneOf
            [ string
            , integerOrIdentifier
            ]


integerOrIdentifier : Parser Item
integerOrIdentifier =
    oneOf
        [ backtrackable <|
            succeed (negate >> Int)
                |. symbol "-"
                |= int
        , backtrackable <| Parser.map Int int
        , identifier
        ]


string : Parser Item
string =
    succeed Str
        |. symbol "\""
        |= getChompedString (chompUntil "\"")
        |. symbol "\""


identifier : Parser Item
identifier =
    let
        isIdentifier c =
            Char.isAlpha c || String.any ((==) c) "<=>!$%&^?+-*/_ "

        nonEmpty id =
            if String.isEmpty id then
                Parser.problem "empty identifier"

            else
                succeed id
    in
    getChompedString (chompWhile isIdentifier)
        |> Parser.andThen nonEmpty
        |> Parser.map Id
