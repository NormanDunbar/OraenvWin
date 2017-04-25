Files List
==========

There are a number of *interesting* files in this folder:

- **\*.cbp** are CodeBlocks project files. These are setup to compile with the free Borland/Embarcadero C++ compiler version 10.1 (at least, in my configuration of CodeBlocks they are!) - you may need to change this for your setup.
- **\*.cpp** are the source files for the various executables used by the ``oraenv`` batch file.

If you don't have the Borland compiler, it's free, head over to http://www.embarcadero.com and get a freebie! Alternatively, use yor own compiler.

  **Note:** The *.cpp files have only been tested with the Borland compiler and the TDM 64bit version of g++ for Windows. You can compile the cources with g++ as follows:
  
  ..  code-block:: none
  
      g++ -o DBPath.exe -std=c++11 DBPath.cpp
      
 and so on.
