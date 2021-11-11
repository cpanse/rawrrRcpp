namespace RawrrEmbed
{
  using System;
  using System.Collections.Generic;
  using System.Diagnostics;
  using System.IO;
  using System.Runtime.ExceptionServices;
  using System.Collections;
  using System.Linq;

  using ThermoFisher.CommonCore.Data;
  using ThermoFisher.CommonCore.Data.Business;
  using ThermoFisher.CommonCore.Data.FilterEnums;
  using ThermoFisher.CommonCore.Data.Interfaces;
  using ThermoFisher.CommonCore.MassPrecisionEstimator;
  using ThermoFisher.CommonCore.RawFileReader;

  class RawRr
  {
    //string rawrr_version = "1.3.0";
    string errormsg = "";
    string filename = null;
      ThermoFisher.CommonCore.Data.Interfaces.IRawDataPlus rawFile;

    //ThermoFisher.CommonCore.Data.Interfaces.IRawDataPlus rawFile = ThermoFisher.CommonCore.RawFileReader.RawFileReaderAdapter.FileFactory (filename);
    //rawFile.SelectInstrument(Device.MS, 1);

    // Process processBefore = Process.GetCurrentProcess();
    // long memoryBefore = processBefore.PrivateMemorySize64 / 1024;

      RawRr ()
    {
      //          this.filename = @"/home/cp/__checkouts/bioc/rawrr/inst/extdata/sample.raw";
      this.filename = @"/tmp/sample.raw";
      //   this.filename = @"sample.raw";
      //this.rawFile = ThermoFisher.CommonCore.RawFileReader.RawFileReaderAdapter.FileFactory (this.filename);
      //this.rawFile.SelectInstrument (Device.MS, 1);
      //Console.WriteLine("RawRr constructor");
    }

    string[] LastSpectrum2 ()
    {
      String[]str = new String[]
      {
      "1", "2", "3.1", "4"};

      return (str);
    }

    string[]get_info ()
    {
      String[]rv = new String[7];
      Process currentProcess = Process.GetCurrentProcess ();
      rv[0] = System.Reflection.Assembly.GetExecutingAssembly ().CodeBase;
      rv[1] =
	System.Reflection.Assembly.
	GetAssembly (typeof (IRawDataPlus)).Location;
      rv[2] = currentProcess.ToString ();
      rv[3] = "currentProcess.Id:\t" + currentProcess.Id.ToString ();
      rv[4] =
	"PrivateMemorySize64 (KB):\t" +
	(currentProcess.PrivateMemorySize64 / 1024).ToString ();
      rv[5] = "Error message:\t" + this.errormsg;
      rv[6] = "raw file name:\t" + this.filename;
      /*
         try{
         long length = new System.IO.FileInfo(this.filename).Length;
         rv[7] = "raw file size:\t" + length.ToString();
         }catch (Exception ex)
         {
         rv[7] = "raw file size:\tcan not be determined catch Exception. " + ex.Message;
         }
       */
      //this.rawFile.SelectInstrument (Device.MS, 1);

      return (rv);
    }

    string[]trailer (int idx)
    {
      var scanTrailer = rawFile.GetTrailerExtraInformation (idx);
      var trailerValues = scanTrailer.Values;
      var trailerLabels = scanTrailer.Labels;
      var zipTrailer = trailerLabels.ToArray ().Zip (trailerValues, (a, b) => string.Format ("{0}={1}", a, b)).ToArray();
      return zipTrailer;
    }

    /// TODO: rename peakValues
    string[]mZvalues (int idx)
    {
      var scan = Scan.FromFile (rawFile, idx);

      var mZ = scan.CentroidScan.Masses.ToArray ();
      var intensities = scan.CentroidScan.Intensities.ToArray ();

      String[]mZString = new String[2 * mZ.Length];

      for (int i = 0; i < mZ.Length; i++)
	mZString[i] = mZ[i].ToString ();

      for (int i = mZ.Length; i < 2 * mZ.Length; i++)
	mZString[i] = intensities[i - mZ.Length].ToString ();

      return mZString;
    }

    int get_Revision ()
    {
      try
      {
	File.Exists (this.filename);
      } catch (Exception ex)
      {
	this.errormsg =
	  "raw file size:\tcan not be determined catch Exception. >>" +
	  ex.Message + "<<\n";
      }

      try
      {
	this.errormsg += "\n#";
	this.rawFile =
	  ThermoFisher.CommonCore.RawFileReader.RawFileReaderAdapter.
	  FileFactory (this.filename);

	if (!this.rawFile.IsOpen || this.rawFile.IsError)
	  {
	    this.errormsg +=
	      "Unable to access the RAW file using the RawFileReader class!";
	  }
	if (this.rawFile.IsError)
	  {
	    this.errormsg += rawFile.FileError;
	  }
      }
      catch (Exception ex)
      {
	this.errormsg +=
	  "Error accessing RAWFileReader library! - " + ex.Message;
      }
      this.rawFile.SelectInstrument (Device.MS, 1);
      return (this.rawFile.FileHeader.Revision);
      return (rawFile.FileHeader.Revision);
    }

    private static void Main (string[]args)
    {
      //string codeBase = System.Reflection.Assembly.GetExecutingAssembly().CodeBase;
      //string fullPath = System.Reflection.Assembly.GetAssembly(typeof(IRawDataPlus)).Location;
      //Console.WriteLine(codeBase);
      //Console.WriteLine(fullPath);
      //Console.WriteLine(System.Reflection.Assembly.GetExecutingAssembly().Location);

      //          RawRr R = new RawRr();
      //          foreach (var msg in R.get_info()){
      //             Console.WriteLine(msg);
      //          }
      //          Console.WriteLine(R.get_Revision());
    }
  }
}
