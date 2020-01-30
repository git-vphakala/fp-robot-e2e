*** Settings ***
Documentation     Findpairs end to end testing.
...    This test assumes that Findpairs Users contains Helmi and Veera.

Library           Collections
Library           SeleniumLibrary
Library           FindPairsTestLibrary.py

*** Variables ***
${FINDPAIRS URL}         http://127.0.0.1:8000/findpairs/
${BROWSER}               chrome
${level-easy}            div.select-level-row > span.spruit-field > span:nth-child(2) > span
${create-game-button}    div.c-game > button
${first-game}            div.online > div:nth-child(4) > button

*** Test Cases ***
Findpairs
    Open Browsers To Findpairs

    &{browserMap}=    Create Dictionary
    Sign In        Veera    player1    ${browserMap}
    Sleep          3s    Let browser render the page
    Create Game    ${level-easy}
    Sleep          3s    Let server create the game and browser to render it
    Join Game      ${first-game}

    Sign In        Helmi    player2    ${browserMap}
    Sleep          3s    Let browser render the page
    Join Game      ${first-game}
    Sleep          3s    Let browser render before Study Turns

    @{turns}=      Study Turns
    Do Turns       ${turns}    ${browserMap}

    @{scoreByPairs}=    Create List    3    2
    @{scoreByUsers}=    Create List    Helmi    Veera
    Score should be    ${scoreByPairs}    ${scoreByUsers}

*** Keywords ***
Open Browsers To Findpairs
    Open Browser    ${FINDPAIRS URL}    ${BROWSER}    alias=player1
    Open Browser    ${FINDPAIRS URL}    ${BROWSER}    alias=player2

Sign In
    [Arguments]    ${user}    ${browser}    ${browserMap}

    Switch Browser        ${browser}
    Location Should Be    ${FINDPAIRS URL}
    Input Text            css:input.name    ${user}
    Click Element         css:i.fa.fa-sign-in
    Set To Dictionary     ${browserMap}    ${user}=${browser}

Create Game
    [Arguments]    ${level}

    Click Element    css:${level}
    Click Element    css:${create-game-button}

Join Game
    [Arguments]    ${game}
    Click Element    css:${game}

Study Turns
    @{local turns} =    Execute JavaScript
                        ...    let cards = [];
                        ...    document.querySelectorAll("div.board span.card > label > i").forEach(elem => cards.push(elem.className));
                        ...    cards = cards.map((classes, i) => ({classes:classes, position:i}));
                        ...    cards = cards.sort((a, b) => a.classes.localeCompare(b.classes));
                        ...    console.log("Get Turns", cards);
                        ...    return cards;

    [Return]    ${local turns}

Turn One Card
    [Arguments]         ${turn}    ${browserMap}

    ${user}=            Get Element Attribute    css:div.board div.header span.turn.active    innerHTML
    Switch Browser      ${browserMap}[${user}]

    ${base}=            Convert To Integer    3
    ${nthchild}=        Evaluate    ${base} + ${turn}[position]
    ${nthchild}=        Convert To String    ${nthchild}
    ${cardSelector}=    Set Variable    div.board > span > span:nth-child(${nthchild})
    Click Element       css:${cardSelector}
    Sleep               3s

Do Turns
    [Arguments]    ${turns}    ${browserMap}

    FOR    ${turn}    IN    @{turns}
        Turn One Card    ${turn}    ${browserMap}
    END

Score Should Be
    [Arguments]    ${expectedScoreByPairs}    ${expectedScoreByUsers}

    @{scoreByUsers} =    Execute JavaScript
                         ...    let scoreByUsers = [];
                         ...    document.querySelectorAll("table > tbody > tr > td:nth-child(2)").forEach(elem => scoreByUsers.push(elem.innerText));
                         ...    console.log("Score Should Be by users", scoreByUsers);
                         ...    return scoreByUsers;

    @{scoreByPairs} =    Execute JavaScript
                         ...    let scoreByPairs = [];
                         ...    document.querySelectorAll("table > tbody > tr > td:nth-child(3)").forEach(elem => scoreByPairs.push(elem.innerText));
                         ...    console.log("Score Should Be by pairs", scoreByPairs);
                         ...    return scoreByPairs;

    Check Scores    ${scoreByUsers}    ${expectedScoreByUsers}
    Check Scores    ${scoreByPairs}    ${expectedScoreByPairs}
