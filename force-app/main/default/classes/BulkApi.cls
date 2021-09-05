public with sharing class BulkApi {

    public Enum Op{
        DML_INSERT
        ,DML_UPDATE
        ,DML_DELETE
    }

/**
 * @description コンストラクタ
 * @throws NoSessionIdException セッションId空白時
 */
    public BulkApi(String sessionId){
        this.sessionId = sessionId;

        if( String.isBlank(this.sessionId) ){
            throw new NoSessionIdException(MSG_ERR_BLANK_SESSION_ID);
        }
    }

/**
 * @description 一括データ読み込みジョブ登録
 * @param sobjectApiName ジョブ処理対象オブジェクトAPI名
 * @return Id 一括データ読み込みジョブId
 * @throws CalloutException ジョブ登録失敗
 */
    public Id createBulkDataLoadJob(String sobjectApiName, Op operationEnum){
        HttpResponse response = new Http().send( getCreateJobRequest(sobjectApiName, operationEnum) );

        Id bulkDataLoadJobId = null;

        Integer statusCode = response.getStatusCode();
//System.debug('createBulkDataLoadJob: ' + statusCode);
        Map<String, String> createJobResults = parseResponse( response.getBody() );

        if(HTTP_STATUS_CREATED == statusCode){
            bulkDataLoadJobId = Id.valueOf( createJobResults.get(XML_TAG_ID) );
        }
        else {
            throw new CalloutException(
                MSG_ERR_FAILED_TO_CREATE_JOB + statusCode + ': ' + createJobResults.get(XML_TAG_ERR_MSG)
            );
        }

        return bulkDataLoadJobId;
    }

/*
 * 一括データ読み込みジョブ登録用HttpRequest作成
 */
    private HttpRequest getCreateJobRequest(String sobjectApiName, Op operationEnum){

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_BULK_API_JOB);
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', this.sessionId);
        req.setHeader('Content-Type', 'application/xml; charset=UTF-8');

        String bodyXml = getCreateJobInfoXml(
            getDmlString(operationEnum)
            ,sobjectApiName
            ,'JSON'
        );

        req.setBody(bodyXml);

        return req;
    }

// Bulk api のdmlは全部小文字
    private static String getDmlString(Op operationEnum){
        String result = '';

        if(Op.DML_INSERT == operationEnum){
            result = 'insert';
        }
        else if(Op.DML_UPDATE == operationEnum){
            result = 'update';
        }
        else if(Op.DML_DELETE == operationEnum){
            result = 'delete';
        }
        return result;
    }

/*
 * 一括データ読み込みジョブ登録用XML作成
 */
    private String getCreateJobInfoXml(String dmlOperation, String sobjectApiName, String contentType){
        XmlStreamWriter xmlWriter = new XmlStreamWriter();

        xmlWriter.writeStartDocument('UTF-8', '1.0');
        xmlWriter.writeEndDocument();

        xmlWriter.writeStartElement('', 'JobInfo', '');
        xmlWriter.writeAttribute('', '',  'xmlns', 'http://www.force.com/2009/06/asyncapi/dataload');

        xmlWriter.writeStartElement('', 'operation', '');
        xmlWriter.writeCharacters(dmlOperation);
        xmlWriter.writeEndElement();

        xmlWriter.writeStartElement('', 'object', '');
        xmlWriter.writeCharacters(sobjectApiName);
        xmlWriter.writeEndElement();

        xmlWriter.writeStartElement('', 'contentType', '');
        xmlWriter.writeCharacters(contentType);
        xmlWriter.writeEndElement();

// concurrencyMode は設定出来ない。(400: Bad Request)
//        xmlWriter.writeStartElement('', 'concurrencyMode', '');
//        xmlWriter.writeCharacters('Serial');
//        xmlWriter.writeEndElement();

        xmlWriter.writeEndElement();

        String jobInfoXml = xmlWriter.getXmlString();

        xmlWriter.close();

        return jobInfoXml;
    }

/*
 * HttpResponseのBodyをMAPに変換する
 */
    private Map<String, String> parseResponse(String responseBody){
// MAP<[XMLタグ名], [値]>
        Map<String, String> parseResult = new Map<String, String>();

        if( String.isNotBlank(responseBody) ){

            XmlStreamReader xmlReader = new XmlStreamReader(responseBody);

            String currentXmlTag = '';
            while ( xmlReader.hasNext() ) {

                if( xmlReader.hasName() ){
                    currentXmlTag = xmlReader.getLocalName();

                    if( parseResult.containsKey(currentXmlTag) == false){
                        parseResult.put(currentXmlTag, null);
                    }
                }
                else if( xmlReader.hasText() ){
                    if( parseResult.containsKey(currentXmlTag)
                        && String.isBlank(parseResult.get(currentXmlTag)) ){

                        parseResult.put( currentXmlTag, xmlReader.getText() );
                    }
                }
                xmlReader.next();
            }
        }

        return parseResult;
    }

/**
 * @description 一括データ読み込みジョブをクローズする。
 *              Batch登録する前にジョブをクローズするとBatchの登録が出来なくなってしまう
 *
 * @param jobId クローズ対象一括データ読み込みジョブId
 * @throws CalloutException ジョブクローズ失敗
 */
    public void closeBulkDataLoadJob(Id jobId){

        validateJobId(jobId);

        HttpResponse response = new Http().send( getCloseJobRequest(jobId, this.sessionId) );

        Integer statusCode = response.getStatusCode();
//System.debug('closeBulkDataLoadJob: ' + statusCode);
        if( HTTP_SUCCESS_CODES.contains(statusCode) == false ){

            Map<String, String> createJobResults = parseResponse( response.getBody() );

            throw new CalloutException(
                MSG_ERR_FAILED_TO_CLOSE_JOB + statusCode + ': ' + createJobResults.get(XML_TAG_ERR_MSG)
            );
        }
    }

    private void validateJobId(Id jobId){
        if(jobId == null){
            throw new NoJobIdException(MSG_ERR_BLANK_JOB_ID);
        }
    }

    private HttpRequest getCloseJobRequest(Id jobId, String sessionId){

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_BULK_API_JOB + '/' + jobId);
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', sessionId);
        req.setHeader('Content-Type', 'application/xml; charset=UTF-8');

        req.setBody( getCloseJobInfoXml() );

        return req;
    }

/*
 * 一括データ読み込みジョブクローズ用XML作成
 */
    private String getCloseJobInfoXml(){
        XmlStreamWriter xmlWriter = new XmlStreamWriter();

        xmlWriter.writeStartDocument('UTF-8', '1.0');
        xmlWriter.writeEndDocument();

        xmlWriter.writeStartElement('', 'JobInfo', '');
        xmlWriter.writeAttribute('', '',  'xmlns', 'http://www.force.com/2009/06/asyncapi/dataload');

        xmlWriter.writeStartElement('', 'state', '');
        xmlWriter.writeCharacters('Closed');
        xmlWriter.writeEndElement();

        xmlWriter.writeEndElement();

        String jobInfoXml = xmlWriter.getXmlString();

        xmlWriter.close();

        return jobInfoXml;
    }

/**
 * @description Bulk Api でレコードを更新する。
 *              HttpRequestを送信して、
 *              一括データ読み込みジョブのBatchを登録する
 *
 * @param recordList 更新対象レコードのLIST
 */
    public void updateRecords(Id jobId, List<Sobject> recordList){

        validateJobId(jobId);

        HttpResponse response = new Http().send( getCreateBatchRequest(jobId, this.sessionId, recordList) );

        Integer statusCode = response.getStatusCode();
//System.debug('updateRecords: ' + statusCode);
        if(HTTP_STATUS_CREATED != statusCode){

            Map<String, String> createJobResults = parseResponse( response.getBody() );

            throw new CalloutException(
                MSG_ERR_BATCH_FAILED + statusCode + ': ' + createJobResults.get(XML_TAG_ERR_MSG)
            );
        }
    }

    private HttpRequest getCreateBatchRequest(Id jobId, String sessionId, List<Sobject> recordList){

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_BULK_API_JOB + '/' + jobId + BULK_API_PATH_BATCH);
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', sessionId);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');

        req.setBody( JSON.serialize(recordList) );

        return req;
    }

    public class NoSessionIdException extends System.Exception {}
    public class NoJobIdException extends System.Exception {}

    private String sessionId = null;

    @testVisible private static final String ENDPOINT_SF_BASE = Url.getSalesforceBaseUrl().toExternalForm();
    @testVisible private static final String ENDPOINT_BULK_API = ENDPOINT_SF_BASE + '/services/async/50.0';
    @testVisible private static final String BULK_API_PATH_JOB = '/job';
    @testVisible private static final String BULK_API_PATH_BATCH = '/batch';
    @testVisible private static final String ENDPOINT_BULK_API_JOB = ENDPOINT_BULK_API + BULK_API_PATH_JOB;

    private static final Integer HTTP_STATUS_OK = 200;
    private static final Integer HTTP_STATUS_CREATED = 201;
    private static final Integer HTTP_STATUS_ACCEPTED = 202;

    private static final String XML_TAG_ID = 'id';
    private static final String XML_TAG_ERR_MSG = 'exceptionMessage';

    private static final Set<Integer> HTTP_SUCCESS_CODES = new Set<Integer>{
        HTTP_STATUS_OK
        ,HTTP_STATUS_ACCEPTED
    };

    @testVisible private static final String MSG_ERR_BLANK_SESSION_ID = 'セッションIdが取得出来ません。';
    @testVisible private static final String MSG_ERR_BLANK_JOB_ID = '一括データ読み込みジョブIdが取得出来ません。';
    @testVisible private static final String MSG_ERR_FAILED_TO_CREATE_JOB = '一括データ読み込みジョブ作成請求失敗しました: ';
    @testVisible private static final String MSG_ERR_FAILED_TO_CLOSE_JOB = '一括データ読み込みジョブクローズ請求失敗しました: ';
    @testVisible private static final String MSG_ERR_BATCH_FAILED = 'バッチ登録請求失敗しました: ';
}