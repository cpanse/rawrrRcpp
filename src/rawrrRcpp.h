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
#include <fstream>

#ifndef FALSE
#define FALSE 0
#endif

#include <iostream>

#include <Rcpp.h>
using namespace Rcpp;

class Rawrr
{
  std::string rawFile = "/tmp/sample.raw";
  std::string assemblyFile = "rawrrRcpp.exe";
  MonoDomain *domain;
  MonoAssembly *assembly;
  MonoImage *image;

  MonoMethod *function_set_rawFile;
  MonoMethod *function_get_Revision;
  MonoMethod *function_get_info;
  MonoMethod *function_get_mZvalues;
  MonoMethod *function_get_trailer;
  MonoClass *Raw;
  MonoObject *obj;

private:

public:
    Rawrr ()
  {
    std::cout << "cpp: Rawrr()" << std::endl;
    std::ifstream my_file (rawFile.c_str ());
    if (my_file.good ())
      {
	// read away
      }
    else
      {
	std::cout << "FILE IS NOT GOOD!" << std::endl;
      }
    mono_config_parse (NULL);
    domain = mono_jit_init_version ("rawrrr", "v4.0");
  }

  void setAssembly (std::string file)
  {
    Rcpp::Rcout << assemblyFile << std::endl;
    assemblyFile = file;
    Rcpp::Rcout << assemblyFile << std::endl;
  }

  void setRawFile (std::string file)
  {
    Rcpp::Rcout << rawFile << std::endl;
    rawFile = file;
    Rcpp::Rcout << rawFile << std::endl;

    MonoString *str;
    void *args[1];
    MonoObject *exception;
    str = mono_string_new (domain, rawFile.c_str ());
    args[0] = &str;
    exception = NULL;
    mono_runtime_invoke (function_set_rawFile, obj, args, &exception);
    if (exception)
      {
	Rcpp::Rcout << "Exception was raised in setRawFile\n";
      }
  }

  void createObject ()
  {

    assembly = mono_domain_assembly_open (domain, assemblyFile.c_str ());

    if (!assembly)
      {
	printf ("ASSEMBLY PROBLEM\\n");
	exit (2);
      }

   // int argc = 2;
   // char *argv[] = { (char *) "rawrrRcpp.exe",
   //  (char *) "rawrrRcpp.exe", NULL
   // };


    // CALLS MAIN OF CS PROGRAM
 //   printf ("cpp: Call main\n");
 //   mono_jit_exec (domain, assembly, argc - 1, argv + 1);

    image = mono_assembly_get_image (assembly);

    Raw = mono_class_from_name (image, "RawrrEmbed", "RawRr");
    if (!Raw)
      {
	fprintf (stderr, "Can't find RawRr in assembly %s\n",
		 mono_image_get_filename (image));
	exit (1);
      }
    printf ("cpp: 1. createObject() - mono_class_from_name\n");

    obj = mono_object_new (domain, Raw);
    printf ("cpp: 2. createObject() - mono_object_new\n");
    mono_runtime_object_init (obj);
    printf ("cpp: 3. createObject() - mono_runtime_object_init\n");

    /// browse class methods
    MonoClass *klass;
    MonoMethod *m = NULL;
    void *iter;

    klass = mono_object_get_class (obj);
    domain = mono_object_get_domain (obj);

    function_get_Revision = NULL;
    function_get_info = NULL;
    function_get_mZvalues = NULL;
    function_get_trailer = NULL;
    function_set_rawFile = NULL;
    iter = NULL;
    while ((m = mono_class_get_methods (klass, &iter)))
      {
	printf ("cpp: method = %s\n", mono_method_get_name (m));
	if (strcmp (mono_method_get_name (m), "get_Revision") == 0)
	  {
	    function_get_Revision = m;
	  }
	else if (strcmp (mono_method_get_name (m), "get_info") == 0)
	  {
	    function_get_info = m;
	  }
	else if (strcmp (mono_method_get_name (m), "mZvalues") == 0)
	  {
	    function_get_mZvalues = m;
	  }
	else if (strcmp (mono_method_get_name (m), "trailer") == 0)
	  {
	    function_get_trailer = m;
	  }
	else if (strcmp (mono_method_get_name (m), "setRawFile") == 0)
	  {
	    function_set_rawFile = m;
	  }
	else
	  {
	  }
      }				//while
  }

  CharacterVector get_trailer (int scanIdx)
  {
    void *args[2];
    int val;
    MonoObject *exception;
    val = scanIdx;
    args[0] = &val;
    exception = NULL;
    MonoArray *resultArray =
      (MonoArray *) mono_runtime_invoke (function_get_trailer, obj, args,
					 &exception);
    if (exception)
      {
	return (-1);
      }
    CharacterVector rv (mono_array_length (resultArray));
    for (unsigned int i = 0; i < mono_array_length (resultArray); i++)
      {
	MonoString *s = mono_array_get (resultArray, MonoString *, i);
	char *s2 = mono_string_to_utf8 (s);
	rv[i] = s2;
      }
    return (rv);
  }

  NumericVector get_mZvalues (int scanIdx)
  {
    void *args[2];
    int val;
    MonoObject *exception;
    val = scanIdx;
    args[0] = &val;
    exception = NULL;
    MonoArray *resultArray =
      (MonoArray *) mono_runtime_invoke (function_get_mZvalues, obj, args,
					 &exception);
    if (exception)
      {
	return (-1);
      }
    NumericVector rv (mono_array_length (resultArray));
    for (unsigned int i = 0; i < mono_array_length (resultArray); i++)
      {
	MonoString *s = mono_array_get (resultArray, MonoString *, i);
	char *s2 = mono_string_to_utf8 (s);
	rv[i] = atof (s2);
      }
    return (rv);
  }


  int get_Revision ()
  {
    MonoObject *result, *exception;
    int val;

    exception = NULL;
    result =
      mono_runtime_invoke (function_get_Revision, obj, NULL, &exception);
    if (exception)
      {
	printf ("An exception was thrown  get_Revision()\n");
	return (-1);
      }

    val = *(int *) mono_object_unbox (result);

    //int retval = mono_environment_exitcode_get ();

    return (val);
  }

  int get_info ()
  {
    printf ("cpp: GET_INFO_BEGIN\n");
    MonoObject *exception;

    exception = NULL;

    MonoArray *result =
      (MonoArray *) mono_runtime_invoke (function_get_info, obj, NULL,
					 &exception);

    if (exception)
      {
	printf ("An exception was thrown  get_info()\n");
	return (-1);
      }

    for (unsigned int i = 0; i < mono_array_length (result); i++)
      {
	MonoString *s = mono_array_get (result, MonoString *, i);
	char *s2 = mono_string_to_utf8 (s);
	printf ("cpp: INFO: %s\n", s2);
      }

    printf ("cpp: GET_INFO_END\n");
    return (0);
  }

};				//class
