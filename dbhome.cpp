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
// A small routine to extract the database home, aka ORACLE_HOME, from a text file
// known as ORATAB. The environment variable ORATAB should be set before calling this
// utility, and it should point at the location of the afore mentioned oratab file.
//=======================================================================================
// Norman Dunbar
// 19 April 2017.
//=======================================================================================
// ORATAB FILE FORMAT:
//=======================================================================================
//
// ORACLE_SID | ORACLE_HOME |# Optional Comment.
//
// If a comment is present in the third field, it must be after a '|#' character pair.
// No spaces between them are permitted.
//
// ORACLE_SID and ORACLE_HOME must not have embedded spaces. Oracle won't work if so.
//
// The first two fields can have spaces before and/or after the pipe character.
// A leading '#' marks a line as a comment. It can have spaces ahead of it if required.
//
// Unlike Unix, we can't use a colon as the separator as it is highly likely that the
// Oracle home location will be on a disc that has a single letter and a colon for its name
// this being Windows!
//
//=======================================================================================
// ORATAB LOCATION SEARCH:
//=======================================================================================
// The file is found as follows:
//
// 1. Using the %oratab% environment variable;
// 2. Looking in %oracle_base%\oratab.txt;
// 3. Looking in the folder where the executable ran from for oratab.txt.
//=======================================================================================
// ERROR RETURNS:
//=======================================================================================
// 0 - All is well, SID found, ORACLE_HOME output on cout. (stdout).
// 1 - No SID supplied on the command line.
// 2 - Cannot open an oratab file.
// 3 - Supplied SID is not found in the oratab file.
// 4 - Memory allocation problem.
//=======================================================================================

#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <algorithm>


using namespace std;

const int NO_ERROR = 0;
const int ERROR_NO_SID = 1;
const int ERROR_CANNOT_OPEN = 2;
const int ERROR_NOT_FOUND = 3;
const int ERROR_NO_MEMORY = 4;


// Attempt to locate and open the oratab file.
ifstream *findOpenOratab();

// Attempt to open an oratab file.
ifstream *openOratab(const string &oraTab);

// Read the oratab and tidy up each entry accordingly.
vector<string> *readOratab(ifstream *ifs);


// Globals! (Yes, I know!)
string exeDirectory;



string stringLower(string &source);


//=======================================================================================
// Start here folks!
//=======================================================================================
int main(int argc, char *argv[])
{
    string oracleSid;
    ifstream *ifs = nullptr;

    // Any parameters? We need the ORACLE_SID.
    if (argc != 2) {
        cerr << "DBHome: ORACLE_SID not passed." << endl;
        return ERROR_NO_SID;
    }

    // Grab the SID & lower case it.
    // Thanks: http://en.cppreference.com/w/cpp/algorithm/transform
    oracleSid = string(argv[1]);
    transform(oracleSid.begin(), oracleSid.end(), oracleSid.begin(),
              [](unsigned char c) { return std::tolower(c); } );

    // Tag on a '|' so we check for the whole ORACLE_SID not just part of it.
    oracleSid += "|";

    // Just in case we don't find oratab/oracle_base...
    exeDirectory = string(argv[0]);
    exeDirectory = exeDirectory.substr(0, exeDirectory.find_last_of("\\"));

    // Find and open the oratab file.
    ifs = findOpenOratab();
    if (ifs == nullptr) {
        cerr << "DBHome: Cannot open oratab file(s)." << endl;
        return ERROR_CANNOT_OPEN;
    }

    // Attempt to read the ORATAB file.
    vector<string> *oratabEntries = readOratab(ifs);

    // Clean up...
    ifs->close();
    delete ifs;

    // Did we allocate space to read into?
    if (oratabEntries == nullptr) {
        return ERROR_NO_MEMORY;
    }

    // Can we find the supplied ORACLE_SID at the start of the string(s)?
    // Ignoring letter case, and immediately followed by a pipe?
    for (auto i = oratabEntries->begin(); i != oratabEntries->end(); i++) {
        if ((*i).find(oracleSid) == 0) {
            // We have a match. Display its ORACLE_HOME for shell use.
            cout << (*i).substr((*i).find("|") + 1);
            delete oratabEntries;
            return NO_ERROR;
        }
    }

    // Tidy up - return not found.
    delete oratabEntries;
    return ERROR_NOT_FOUND;
}


//=======================================================================================
// Search for and attempt to open an oratab.txt file.
//=======================================================================================
 ifstream *findOpenOratab() {
    // Checks if we have a valid file that we can read.
    string oraTab;

    // Do we have %ORATAB% set?
    // FYI: getenv() here is std::getenv from <cstdlib>.
    char *envOratab = getenv("ORATAB");
    if (envOratab) {
        // We do, try to open it. If it fails, abort.
        oraTab = string(envOratab);
        return openOratab(oraTab);
    }

    // No %oratab%, Do we have %ORACLE_BASE%.\oratab.txt
    envOratab = getenv("ORACLE_BASE");
    if (envOratab) {
        // We do, try to open oratab.txt there. If we don't
        // open it, carry on, do not abort.
        oraTab = string(envOratab) + "\\oratab.txt";
        ifstream *ifs = openOratab(oraTab);
        if (ifs) {
            return ifs;
        }
    }

    // Try the last option, in the current folder.

    oraTab = exeDirectory + "\\oratab.txt";
    return openOratab(oraTab);
}


//=======================================================================================
// Open the string passed as an oratab file. Either works, or not.
//=======================================================================================
ifstream *openOratab(const string &oraTab) {
    ifstream *ifs = new ifstream(oraTab);
    if (!ifs->good()) {
        delete ifs;
        return nullptr;
    }

    // Something opened!
    return ifs;
}


//=======================================================================================
// Read the oratab entries, stripping out comments and blanks, remove comments from each
// entry and dump all the spaces we find in each entry.
//=======================================================================================
vector<string> *readOratab(ifstream *ifs) {
    // Attempt to read the ORATAB file.
    vector<string> *oratabEntries = new vector<string>;
    if (!oratabEntries) {
        cerr << "DBHome: Cannot allocate memory for oratab file." << endl;
        return nullptr;
    }

    string oratabLine;

    while (ifs->good()) {
        // This won't compile if ifs is declared const! Go figure.
        // What don't I understand about getline() then I wonder?
        getline(*ifs, oratabLine);
        if (oratabLine.empty()) continue;

        // Strip off trailing comments. We don't want to waste any
        // time lower casing and stripping spaces from comments. This
        // is why the rules do not allow for spaces between '|' and '#'.
        string::size_type f = oratabLine.find("|#");
        if (f != string::npos) {
            oratabLine = oratabLine.substr(0, f-1);
        }

        // Strip off any and all remaining spaces FROM THE END!
        // We strip from the end as erasing one character moves
        // the rest down, and we would have to check the same
        // character again if stripping from the front.
        for (auto c = oratabLine.end(); c >= oratabLine.begin(); c--) {
            if (*c == ' ') {
                oratabLine.erase(c);
            }
        }

        // We also lowercase the ORACLE_SID here too.
        for (auto c = oratabLine.begin(); c != oratabLine.end(); c++) {
            if (*c == '|') {
                break;
            } else {
                *c = tolower(*c);
            }
        }

        // Ignore comment lines.
        if (oratabLine.at(0) == '#') continue;

        // The remaining string is valid, save it.
        oratabEntries->push_back(oratabLine);
    }

    return oratabEntries;
}


