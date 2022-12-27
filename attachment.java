CREATE TABLE xx_file_blobs
(
    file_id INTEGER,
    Attached_file_Name VARCHAR2 (50),
    Attached_file BLOB,
    ContentType VARCHAR2 (50),
    creation_date DATE,
    created_by NUMBER,
    last_update_date DATE,
    last_updated_by INTEGER,
    last_update_login INTEGER);


-----------------------------------------------------------------------------------------
/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package logi.oracle.apps.lotc.attachment.webui;

import oracle.apps.fnd.framework.OAApplicationModule;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.cabo.ui.data.DataObject;

import oracle.jbo.domain.BlobDomain;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

import java.sql.SQLException;

import oracle.apps.fnd.framework.OAException;

import oracle.jbo.Row;


/**
 * Controller for ...
 */
public class AttachmentCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    /**
     * Layout and page setup logic for a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processRequest(OAPageContext pageContext, OAWebBean webBean) {
        super.processRequest(pageContext, webBean);
        //  AttachmentAMImpl amObj = (AttachmentAMImpl)pageContext.getApplicationModule(webBean);
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        OAViewObject vo = (OAViewObject)am.findViewObject("XxFileBlobsEOVO");
        vo.executeQuery();
        am.invokeMethod("createAttach", null);
    }

    /**
     * Procedure to handle form submissions for form elements in
     * a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processFormRequest(OAPageContext pageContext, 
                                   OAWebBean webBean) {
        super.processFormRequest(pageContext, webBean);
        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        // Select file then hit commit
        if (pageContext.getParameter("CommitBtn") != null) {
            OAViewObject vo = (OAViewObject)am.findViewObject("XxFileBlobsVO");
            oracle.jbo.domain.Number fileId = 
                (oracle.jbo.domain.Number)vo.getCurrentRow().getAttribute("FileId");
            Row row = (Row)vo.getCurrentRow();
            DataObject fileUploadData = 
                (DataObject)pageContext.getNamedDataObject("AttachedFile");
            if (fileUploadData != null) {
                String uFileName = 
                    fileId.toString() + "_" + (String)fileUploadData.selectValue(null, 
                                                                                 "UPLOAD_FILE_NAME");
                String contentType = 
                    (String)fileUploadData.selectValue(null, "UPLOAD_FILE_MIME_TYPE");
                row.setAttribute("AttachedFile", 
                                 createBlobDomain(fileUploadData));
                row.setAttribute("AttachedFileName", uFileName);
                row.setAttribute("Contenttype", contentType);
            }
            // File Upload Ends
            am.invokeMethod("apply");
            String fileName = 
                (String)vo.getCurrentRow().getAttribute("AttachedFileName");
            OAException confirmMessage = 
                new OAException("File " + fileName + " uploaded succesfully .", 
                                OAException.CONFIRMATION);
            pageContext.putDialogMessage(confirmMessage);
        }
    }

    private BlobDomain createBlobDomain(DataObject pfileUploadData) {
        // init the internal variables
        InputStream in = null;
        BlobDomain blobDomain = null;
        OutputStream out = null;
        try {
            String pFileName = 
                (String)pfileUploadData.selectValue(null, "UPLOAD_FILE_NAME");
            BlobDomain uploadedByteStream = 
                (BlobDomain)pfileUploadData.selectValue(null, pFileName);
            // Get the input stream representing the data from the client
            in = uploadedByteStream.getInputStream();
            // create the BlobDomain datatype to store the data in the db
            blobDomain = new BlobDomain();
            // get the outputStream for hte BlobDomain
            out = blobDomain.getBinaryOutputStream();
            byte buffer[] = new byte[8192];
            for (int bytesRead = 0; 
                 (bytesRead = in.read(buffer, 0, 8192)) != -1; )
                out.write(buffer, 0, bytesRead);
            in.close();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.fillInStackTrace();
        }
        // return the filled BlobDomain
        return blobDomain;
    }
}

------------------------------------------------------------------------------------------


package logi.oracle.apps.lotc.attachment.server;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;

import oracle.jbo.Row;

import oracle.apps.fnd.framework.OAViewObject;

import oracle.apps.fnd.framework.server.OADBTransaction;

import oracle.jbo.Transaction;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class AttachmentAMImpl extends OAApplicationModuleImpl {
    /**This is the default constructor (do not remove)
     */
    public AttachmentAMImpl() {
    }

    /**Container's getter for XxFileBlobsEOVO
     */
    public XxFileBlobsEOVOImpl getXxFileBlobsEOVO() {
        return (XxFileBlobsEOVOImpl)findViewObject("XxFileBlobsEOVO");
    }

    /**Sample main for debugging Business Components code using the tester.
     */
    public static void main(String[] args) { /* package name */
            /* Configuration Name */launchTester("logi.oracle.apps.lotc.attachment.server", 
                                                 "AttachmentAMLocal");
    }

    public void createAttach() {
        OAViewObject vo = (OAViewObject)getXxFileBlobsEOVO();
        OADBTransaction tr = getOADBTransaction();
        // Per the coding standards, this is the proper way to initialize a
        // VO that is used for both inserts and queries. See View Objects
        // in Detail in the Developer's Guide for additional information.
        if (!vo.isPreparedForExecution()) {
            vo.executeQuery();
        }
        Row row = vo.createRow();
        vo.insertRow(row);
        // Required per OA Framework Model Coding Standard M69
        row.setNewRowState(Row.STATUS_INITIALIZED);
        vo.getCurrentRow().setAttribute("FileId", 
                                          tr.getSequenceValue("SEQUENCE")); //default Request Id       

    } // end createAttach()

    public void apply() {
        getTransaction().commit();
    } // end apply()

}
