/*
 * MIT License
 *
 * Copyright (c) 2017 Norman Dunbar
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

//=======================================================================================
// A small utility to remove an existing path from %PATH% and return the new version of
// %PATH% to the caller so that the new PATH can be set by the caller.
//
// It has to be this way so that the caller can SET PATH=whatever because we cannot set
// the PATH for the caller from here, we are a child of the caller not a parent. Sigh.
//
// EVERY part of %PATH% containing the passed ORACLE_HOME, will be removed, so if you
// have %PATH% containing some ORACLE_HOME\bin and the same ORACLE_HOME\OPatch etc, then
// the returned PATH will not contain either of them.
//=======================================================================================
// Norman Dunbar
// 20 April 2017.
//=======================================================================================
// ERROR RETURNS:
//=======================================================================================
// 0 - All is well, new setting for PATH output on cout. (stdout).
// 1 - No ORACLE_HOME supplied on the command line.
// 2 - %PATH% is not defined in the caller.
//=======================================================================================

#include <iostream>
#include <string>
#include <cstdlib>

using namespace std;

const int NO_ERROR = 0;
const int ERROR_NO_HOME = 1;
const int ERROR_NO_PATH = 2;



//=======================================================================================
// Start here folks!
//=======================================================================================
int main(int argc, char *argv[])
{
    string oracleHome;
    string oracleHomeLC;
    string currentPath;
    string currentPathLC;

    // Any parameters? We need the ORACLE_HOME to be removed.
    // It will not have "\bin" or even "\OPatch" attached.
    if (argc != 2) {
        cerr << "DBPath: ORACLE_HOME not passed." << endl;
        return ERROR_NO_HOME;
    }

    // Grab the ORACLE_HOME & lower case it.
    oracleHome = string(argv[1]);
    oracleHomeLC.reserve(oracleHome.size());
    for (auto c = oracleHome.begin(); c != oracleHome.end(); c++ ) {
        oracleHomeLC.push_back(tolower(*c));
    }

    // Grab the PATH and copy it to a string.
    char *path = getenv("PATH");
    if (!path) {
        cerr << "DBPath: %PATH% not set. Cannot continue." << endl;
        return ERROR_NO_PATH;
    }

    // Keep a lower case copy of this too.
    currentPath = string(path) + ';';
    currentPathLC.reserve(currentPath.size());
    for (auto c = currentPath.begin(); c != currentPath.end(); c++ ) {
        currentPathLC.push_back(tolower(*c));
    }


    // Scan the lower cased PATH string, looking for the lower
    // cased oracle_home.
    string::size_type start = currentPathLC.find(oracleHomeLC);
    while (start != string::npos) {

        // If we find it, erase it from BOTH strings.
        // Watch out for quoted strings!
        if (start && currentPathLC.at(start-1) == '"') {
            start--;
        }

        // Count up to the following ';' if there is one, or end of string.
        string::size_type semiColon = currentPathLC.find(';', start + oracleHomeLC.size());
        if (semiColon != string::npos) {
            currentPathLC.erase(start, semiColon-start+1);
            currentPath.erase(start, semiColon-start+1);
        }

        // Any more occurrences?
        start = currentPathLC.find(oracleHomeLC);
    }

    cout << currentPath.substr(0, currentPath.size() -1) << endl;
    return NO_ERROR;

}


