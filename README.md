# epub2epub
This library takes EPUB 2.0 and EPUB 3.0 and converts them to more recent standards.

## Options

| Option | Description  |
|---|---|
| href | Path to the EPUB file.  |
| outdir | Where the output will be stored. |
| create-epub  |  Whether to create an EPUB with transpect epubtools module. When set to 'no', the contents and epub-config extracted from the input EPUB are stored to outdir. |
| epub-version | EPUB version for conversion, e.g. 'EPUB2', 'EPUB3'. For example, if the EPUB is simply invalid, you can simply keep the version and repair it. |
| html-subdir-name | Name of the directory where the HTML files are stored in the EPUB package. |
| toc-page | (HTML) page index after there the table of contents (ToC) is inserted. |
| hide-toc | "yes" hides the generated ToC. Pre-existing ToCs remain unaffected. |
| remove-chars-regex | Regular expression which matches characters to be deleted in filenames. |
| debug | Pass "yes" to switch on storing debugging output. |
| debug-dir-uri | The URI where the debug files are stored. |
| status-dir-uri | The URI where messages are stored. |
| terminate-on-error | Abort on error or attempt to catch it. |
