# ---------------------------------------------------------------------------
# Batch job report script
# ---------------------------------------------------------------------------
#
# xml libs from http://www.lfd.uci.edu/~gohlke/pythonlibs/
#
import argparse, os, sys
import errno
import libxml2
import libxslt
       
def safeCreateDir(directory):
    if (directory is None or len(directory) == 0):
        #no directory was provided. Use the current dir
        return os.getcwd()
    #try and make it if it doesn't exist
    try:
        os.makedirs(directory)
    except OSError as e:
        #is it because it already exists?
        if e.errno != errno.EEXIST:
            raise
    return directory

def list_directory(directory):
    #get list of rbjs
    fileList = [os.path.normcase(f)
                for f in os.listdir(directory)]
    fileList = [os.path.join(directory, f)
               for f in fileList
                   if os.path.splitext(f)[1].upper() == ".RBJ"]
    return fileList

def build_rbj_list(top):
    fileList = []

    for root, dirs, files in os.walk(top, followlinks=True):
        fileList += list_directory(root)
        # recursive calls on subfolders
        for dirname in dirs:
            fileList += build_rbj_list(os.path.join(root, dirname))

    return fileList
        


parser = argparse.ArgumentParser(description='Run the batch job report')

parser.add_argument('-o', action="store", dest="output", default="")
parser.add_argument('-xsl', action="store", dest="xslt", default="xform_rbj2.xsl")
parser.add_argument('-rbj', action="store", dest="rbjs", 
                    default="")

args = parser.parse_args()

#check our xslt exists
if (not os.path.exists(args.xslt)):
    #exit
    sys.stdout.write ( "Unable to find xslt '" + args.xslt + "'." )
    sys.exit()

#get our list of RBJs
if (len(args.rbjs) == 0):
    #look for rbjs in the current folder
    args.rbjs = os.getcwd()

#look for rbjs in the specified folder
rbjs = []
if (os.path.isfile(args.rbjs)):
    if (os.path.splitext(args.rbjs)[1].upper() == ".RBJ"):
        rbjs.append(args.rbjs)
else:
    #we assume that it is a directory
    rbjs = build_rbj_list(args.rbjs)

if (rbjs.count == 0):
    sys.stdout.write ( "No batch jobs found to process for -rbj " + args.rbjs)
    sys.exit()

styledoc = libxml2.parseFile(args.xslt)
style = libxslt.parseStylesheetDoc(styledoc)

#create our output folder
OutputFolder = safeCreateDir(args.output)

for rbj in rbjs:
    print "Processing %r..." % rbj
    try:
        rbjDoc = libxml2.parseFile(rbj)
        result = style.applyStylesheet(rbjDoc, None)
        resultFileName = os.path.join(OutputFolder,os.path.splitext(os.path.basename(rbj))[0]) + ".txt"
        print "Saving result to %r" % resultFileName
        if (os.path.isfile(resultFileName)):
            try:
                os.remove(resultFileName)
            except:
                pass #a new version will simply be created
        style.saveResultToFilename(resultFileName, result, 0)
        rbjDoc.freeDoc()
        result.freeDoc()
    except libxml2.parserError as pe:
        print "Parse error %r for %r" % (pe.msg, rbj)
    except:
        print "Unknown error parsing %r" % rbj
    
        
style.freeStylesheet()

sys.stdout.write( "Results written to '" + OutputFolder + "'\n")
sys.stdout.write ( "Execution complete..." )