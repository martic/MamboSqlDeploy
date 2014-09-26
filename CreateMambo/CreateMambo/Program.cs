using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace CreateMambo
{
    class Program
    {
        private const string TEMPLATE_NAME = "MamboTemplate.sql";
        private const string OUTPUT_FILE = "Mambo.sql";
        private const string FILE_SEARCH = "*.sql";
        private const string BEGIN_LOOP = "[BEGIN LOOP]";
        private const string END_LOOP = "[END LOOP]";
        private const string INSERT_FILENAME = "[INSERT FILENAME]";
        private const string INSERT_FILE = "[INSERT FILE]";
        private const string INSERT_SECTION_NUMBER = "[INSERT SECTION NUMBER]";

        private static string[] goDelim = {"GO"};
        private static string outputText = null;
        
        static void Main(string[] args)
        {
            // Open the template file, and extract out the repeated section.
            string template = File.ReadAllText(Directory.GetCurrentDirectory() + "\\" + TEMPLATE_NAME);
            int beginLoopIndex = template.IndexOf(BEGIN_LOOP);
            int endLoopIndex = template.IndexOf(END_LOOP);
            string templateTopHalf = template.Substring(0, beginLoopIndex);
            string templateBottomHalf = template.Substring(endLoopIndex + END_LOOP.Length, template.Length - endLoopIndex - END_LOOP.Length);
            string repeatedTemplate = template.Substring(beginLoopIndex + BEGIN_LOOP.Length, endLoopIndex - beginLoopIndex - BEGIN_LOOP.Length);

            // Create mambo output file.
            File.Delete(OUTPUT_FILE);
            
            // Write out the required template header
            OutputText(templateTopHalf);

            // Get a list of all files we need to compile into the mambo script.
            string[] files = Directory.GetFiles(Directory.GetCurrentDirectory(), FILE_SEARCH);

            // For each file...
            foreach (string file in files)
            {
                // Make sure it's not the Mambo.sql or MamboTemplate
                if (!file.EndsWith(OUTPUT_FILE, StringComparison.CurrentCultureIgnoreCase) && !file.EndsWith(TEMPLATE_NAME, StringComparison.CurrentCultureIgnoreCase))
                {
                    // Read the contents of the file, and split the GO statements.  Scripts b/w 
                    // GO statements are effectively considered a separate file.
                    string[] fileContents = File.ReadAllText(file).Split(new string[] { "GO" }, StringSplitOptions.RemoveEmptyEntries);
                    int sectionNumber = 0;

                    foreach (string fileGOSection in fileContents)
                    {
                        sectionNumber++;
                        string repeatedFilled = repeatedTemplate;
                        repeatedFilled = repeatedFilled.Replace(INSERT_FILENAME, file.Replace(Directory.GetCurrentDirectory() + "\\", ""));
                        repeatedFilled = repeatedFilled.Replace(INSERT_FILE, fileGOSection.Replace("'", "''"));
                        repeatedFilled = repeatedFilled.Replace(INSERT_SECTION_NUMBER, sectionNumber.ToString());

                        OutputText(repeatedFilled);
                    }
                }
            }

            OutputText(templateBottomHalf);

            FinalizeOutputFile();
        }

        private static void OutputText(string text)
        {
            outputText = outputText + text;
        }

        private static void FinalizeOutputFile()
        {
            File.WriteAllText(Directory.GetCurrentDirectory() + "\\" + OUTPUT_FILE, outputText);
        }
    }
}
