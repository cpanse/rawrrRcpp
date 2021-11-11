#ifndef _RAWRRINVOKECS
#include <mono/jit/jit.h>
#endif

#include <mono/metadata/object.h>
#include <mono/metadata/environment.h>
#include <mono/metadata/assembly.h>
#include <mono/metadata/debug-helpers.h>
#include <mono/metadata/mono-config.h>

#include <string.h>
#include <stdlib.h>

#ifndef FALSE
#define FALSE 0
#endif


#include "rawrrRcpp.h"


#ifdef MONO_EMBED_CPP_MAIN
int
main (int argc, char *argv[])
{
  Rawrr RR;

  int rv = -1;

  RR.get_info();
  RR.createObject ();

  for (int i = 0; i < 10; i++)
    {
      rv = RR.get_Revision ();
      std::cout << "cpp(main):\t" << rv << std::endl;
  RR.get_info();
    }

  return (0);

}

#else

#include <Rcpp.h>
using namespace Rcpp;


// Expose the classes
RCPP_MODULE (RawrrMod)
{
  class_ < Rawrr >
    ("Rawrr").default_constructor ("Default constructor").
    method ("createObject", &Rawrr::createObject, "createObject.").method ("get_Revision", &Rawrr::get_Revision, "Returns the rawfile revision.").
    method ("get_info", &Rawrr::get_info, "Returns the rawfile revision.");
}

#endif
