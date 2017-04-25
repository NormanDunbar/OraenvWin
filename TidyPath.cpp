//=======================================================================================
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
// A small routine to fixup various paths in the %PATH% environment variable, where those
// paths have spaces etc in them, but Control Panel has allowed them to be set up without
// double quotes. This is fine for Control Panel, but attempting to set PATH to a string
// without quotes causes the set command to barf. Consistent? Not a bloody chance!
//=======================================================================================
// Norman Dunbar
// 24 April 2017.
//=======================================================================================
// ERROR RETURNS:
//=======================================================================================
// 0 - All is well.
// 1 - %PATH% is not defined in the caller.
//=======================================================================================

#include <iostream>
#include <string>
#include <vector>

using namespace std;

const int NO_ERROR = 0;
const int ERROR_NO_PATH = 1;

int main(int argc, char *argv[])
{
    string currentPath;

    // Grab the current %PATH% and copy it to a string with a
    // temporary semicolon at the end.
    char *path = getenv("PATH");
    if (!path) {
        cerr << "TidyPath: ." << endl;
        return ERROR_NO_PATH;
    }

    currentPath = string(path) + ';';

    // Handy for debugging.
    // cout << "CURRENT PATH" << endl << currentPath << endl << endl;

    // Separate the long string into individual paths.
    vector<string> pathPaths;
    string thisPath;

    // Scan along for the ';' separator. Add each found path to the
    // list of paths, keeping the separators.
    // I suppose I could have used find() and substr() I suppose,
    // but this is easier!
    for (auto c = currentPath.begin(); c != currentPath.end(); c++) {
        thisPath.push_back(*c);
        if (*c == ';') {
            pathPaths.push_back(thisPath);
            thisPath.clear();
        }
    }

    // Rebuild the currentPath adding double quotes where necessary.
    // Preferably, adding  the trailing quote before the semicolon!
    currentPath.clear();
    for (auto x = pathPaths.begin(); x != pathPaths.end(); x++) {
        if ((*x).at(0) == '"') {
            // Already is a quoted path.
            currentPath += *x;

            // Handy  for debugging.
            //cerr << "OK: [" << *x << "]" << endl;
            continue;
        }

        // Unquoted Path. Check for spaces or brackets.
        if (((*x).find(' ') != string::npos) ||
            ((*x).find('(') != string::npos) ||
            ((*x).find('(') != string::npos)) {
            // Unquoted with garbage - Control Panel, I hate you!
            string temp = '"' + (*x).substr(0, (*x).size() - 1) + "\";";
            currentPath += temp;

            // Handy  for debugging.
            //cerr << "FIXED: [" << *x << ']' << endl
            //     << "   TO: [" << temp << ']' << endl;
        } else {
            // No spaces etc found no need to quote it.
            currentPath += *x;

            // Handy  for debugging.
            //cerr << "NOFIX: [" << *x << "]" << endl;
        }
    }

    // All done, display currentPath, with proper quotes.
    // Lose the temporary ';' at the end.
    cout << currentPath.substr(0, currentPath.size() -1);

    return NO_ERROR;
}
