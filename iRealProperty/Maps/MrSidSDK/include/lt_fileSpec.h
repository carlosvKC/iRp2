/* $Id$ */
/* //////////////////////////////////////////////////////////////////////////
//                                                                         //
// This code is Copyright (c) 2004 LizardTech, Inc, 1008 Western Avenue,   //
// Suite 200, Seattle, WA 98104.  Unauthorized use or distribution         //
// prohibited.  Access to and use of this code is permitted only under     //
// license from LizardTech, Inc.  Portions of the code are protected by    //
// US and foreign patents and other filings. All Rights Reserved.          //
//                                                                         //
////////////////////////////////////////////////////////////////////////// */
/* PUBLIC */

#ifndef LT_FILESPEC_H
#define LT_FILESPEC_H

// lt_lib_base
#include "lt_base.h"
#include "lt_system.h"

LT_BEGIN_NAMESPACE(LizardTech)
/**
 * Max length of a path
 */
#ifdef LT_OS_WIN
#define LT_UTIL_MAX_PATH _MAX_PATH
#else
#define LT_UTIL_MAX_PATH 2048
#endif

/**
 * Represents a file or directory path
 */
class LTFileSpec
{
public:
   enum
   {
      fSlash = '/',
      bSlash = '\\',
#ifdef LT_OS_WIN
      platformSlash = '\\'
#else
      platformSlash = '/'
#endif
   };


public:
   /**
    * default constructor
    */
   LTFileSpec(void);

   /**
    * destructor
    */
   ~LTFileSpec(void);

   /**
    * native constructor
    *
    * @param   path    first part of the path could be directory or filename
    *
    * @note On Win32 the file system treats a (char *) as a multibyte string
    *       On Unix/Linux the file system treats a (char *) as a utf8 string
    */
   enum EncodingType { NATIVE, UTF8 };
   LTFileSpec(const char *p1,
              EncodingType encoding = NATIVE);
   LTFileSpec(const char *p1, const char *p2,
              EncodingType encoding = NATIVE);
   LTFileSpec(const char *p1, const char *p2, const char *p3,
              EncodingType encoding = NATIVE);

   
   /**
    * wchar constructor
    * @note See native constructor for arguments
    * @note On Win32 wchar_t is a UTF16 string. On unix it is UTF32
    */
   explicit LTFileSpec(const wchar_t *p1);
   LTFileSpec(const wchar_t *p1, const wchar_t *p2);
   LTFileSpec(const wchar_t *p1, const wchar_t *p2, const wchar_t *p3);
   
#ifndef LT_OS_WIN
   /**
    * UTF16 constructor
    * @note See native constructor for arguments
    */
   explicit LTFileSpec(const lt_uint16 *path);
   LTFileSpec(const lt_uint16 *p1, const lt_uint16 *p2);
   LTFileSpec(const lt_uint16 *p1, const lt_uint16 *p2, const lt_uint16 *p3);
#endif

   LTFileSpec(const LTFileSpec &p1);
   LTFileSpec(const LTFileSpec &p1, const LTFileSpec &p2);
   LTFileSpec(const LTFileSpec &p1, const LTFileSpec &p2, const LTFileSpec &p3);

   LTFileSpec(const LTFileSpec &p1, const char *p2,
              EncodingType encoding);
   LTFileSpec(const LTFileSpec &p1, const char *p2, const char *p3,
              EncodingType encoding);
   LTFileSpec(const LTFileSpec &p1, const LTFileSpec &p2, const char *p3,
              EncodingType encoding);

   LTFileSpec(const LTFileSpec &p1, const wchar_t *p2);
   LTFileSpec(const LTFileSpec &p1, const wchar_t *p2, const wchar_t *p3);
   LTFileSpec(const LTFileSpec &p1, const LTFileSpec &p2, const wchar_t *p3);

#ifndef LT_OS_WIN
   LTFileSpec(const LTFileSpec &p1, const lt_uint16 *p2);
   LTFileSpec(const LTFileSpec &p1, const lt_uint16 *p2, const lt_uint16 *p3);
   LTFileSpec(const LTFileSpec &p1, const LTFileSpec &p2, const lt_uint16 *p3);
#endif

   /*@}*/

   /**
    * assignment operator
    */
   LTFileSpec& operator=(const LTFileSpec &that);

   /**
    * inequality operator
    */
   bool operator!=(const LTFileSpec& fs) const;

   /**
    * equality operator
    */
   bool operator==(const LTFileSpec& fs) const;

   // is the fileSpec empty
   bool empty(void) const;
   
   /**
    * Function to convert the path to a UTF8 format.
    */
   const char *utf8(void) const;
   
   /**
    * Function to convert the path to native format.
    *
    * @note On Win32 this returns a multi-byte string.
    * @note On Unix this returns a UTF8 string.
    */
   const char *n_str(void) const;
   
   /**
    * Function to convert the path to Wide format.
    *
    * @note On Win32 this returns a 16bit UTF16 string. 
    * @note On Unix this returns a 32bit UTF32 string.
    */
   const wchar_t *w_str(void) const;
   /**
    * Return the parent directory
    *
    * The semantics are similar to the standard Unix dirname.
    *
    * Examples:
    * - "/usr/lib" -> "/usr"
    * - "/usr/"    -> "/"
    * - "usr"      -> "."
    * - "/"        -> "/"
    * - "C:/"      -> "C:/"
    * - "."        -> "."
    * - ".."       -> "."
    */
   LTFileSpec dirname(void) const;
   
   /**
    * Return the base filename
    *
    * The semantics are similar to the standard Unix basename.
    *
    * Examples:
    * - "/usr/lib" -> "lib"
    * - "/usr/"    -> "usr/"  (not the same as the unix basename)
    * - "usr"      -> "usr"
    * - "/"        -> "/"
    * - "C:/"      -> "C:/"
    * - "."        -> "."
    * - ".."       -> ".."
    */
   const char *basename(void) const;
   
   /**
    * returns suffix (in utf8)
    *
    * Examples:
    * - "foo.bar" -> "bar"
    * - "foo." -> ""
    * - "foo" -> ""
    */
   const char* getSuffix() const;

   /**
    * replaces suffix (extension)
    *
    * Note that \a ext should not include the ".".
    * If \a ext is null, the suffix is removed.
    *
    * Examples:
    * - "foo.bar" with "baz" -> "foo.baz"
    * - "foo.bar" with ".baz" -> "foo..baz"
    * - "foo.bar" with "" -> "foo."
    * - "foo" with "baz" -> "foo.baz"
    */
   LTFileSpec replaceSuffix(const char* ext) const;

   /**
    * remove the suffix (extension)
    *
    * Note this also removes the ".".
    *
    * Examples:
    * - "foo.bar" -> "foo"
    * - "foo." -> "foo"
    * - "foo" -> "foo"
    */
   LTFileSpec removeSuffix() const;

   /**
    * returns true if path is absolute, false if relative
    */
   bool absolute() const;

protected:
   
   /**
    * Initialization from UTF8 strings
    * 
    */
   void init(const char *p1, const char *p2, const char *p3);
   
   size_t getPrefixLength(void) const;
private:
   // using a utf8 string to hold the path because it is the easiest
   // to play with (we can look for bSlashs and not have to worry 
   // about lead btyes.
   char *m_path8;
   mutable char *m_pathA;     // this will be updated in n_str()
   mutable wchar_t *m_pathW;  // this will be updated in w_str()

};

LT_END_NAMESPACE(LizardTech)

#endif // LT_FILESPEC_H
