/*
 Copyright (©) 2003-2017 Teus Benschop.
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */



#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <cstring>
#include <algorithm>
#include <set>
#include <chrono>
#include <iomanip>
#include <stdexcept>
#include <thread>
#include <cmath>
#include <mutex>
#include <numeric>
#include <random>
#include <limits>



#include "bibledit.h"


using namespace std;


// This is dummy code.
// The purpose is to make development of the iOS app fast and easy.
// The developer can manipulate the values the dummy functions return.


bool bibledit_started = false;


const char * bibledit_get_version_number ()
{
    return "";
}


const char * bibledit_get_network_port ()
{
    return "9876";
}


void bibledit_initialize_library (const char * package, const char * webroot)
{
    bibledit_started = true;
}


void bibledit_set_touch_enabled (bool enabled)
{
}


void bibledit_set_quit_at_midnight ()
{
}


void bibledit_start_library ()
{
    bibledit_started = true;
}


const char * bibledit_get_last_page ()
{
    return "";
}


bool bibledit_is_running ()
{
    this_thread::sleep_for (chrono::milliseconds (10));
    if (bibledit_started) return true;
    return false;
}


const char * bibledit_is_synchronizing ()
{
    return "false";
}


const char * bibledit_get_external_url ()
{
    return "";
}


// Returns the pages the calling app should open.
const char * bibledit_get_pages_to_open ()
{
    return "";
}


void bibledit_last_ditch_forced_exit ()
{
}


void bibledit_stop_library ()
{
    bibledit_started = false;
}


void bibledit_shutdown_library ()
{
    bibledit_started = false;
}


void bibledit_log (const char * message)
{
}
