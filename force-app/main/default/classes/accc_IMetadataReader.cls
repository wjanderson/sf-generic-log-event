/**
 * @File Name          : accc_IMetadataReader.cls
 * @Description        : defines the reader contracts. Apex does not make it easy
                         in that is does not define a IStream for XmlStreamReader and XmlStreamWriter;
                         and I wish to hide the fact I am either reading/writing XML, JSON, etc. as
                         this too tighly couples the readers and writers since I wish to vary the behavior
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/5/2019    Bill Anderson      Initial Version
 **/

public interface accc_IMetadataReader {
    /*
     * read the metadata
     */
    Object reader(String input);

}// end of accc_IMetadataReader