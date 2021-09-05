@isTest
public class BulkApiCalloutMock implements HttpCalloutMock {
    // コールアウト結果Enum
    public Enum Result{
        SUCCESS
        ,FAILED
    }

    //コールアウト結果Enum
    private Result calloutMockResult;
    //BulkApiレスポンスMockクラス
    private BulkApiResponseMock responseMockType;

    public BulkApiCalloutMock(BulkApiResponseMock responseMock, Result mockResultEnum) {
        this.responseMockType = responseMock;
        this.calloutMockResult = mockResultEnum;
    }

    /**
     * HttpCalloutMock インタフェースメソッド実装
     */
    public HttpResponse respond(HttpRequest req) {

        if(Result.SUCCESS == this.calloutMockResult){
            // コールアウト成功をMockする場合、HTTPリクエストの正しさを検証する
            this.responseMockType.verifyHttpRequest(req);
        }
        // Mock対象リスポンスを返す
        return this.responseMockType.createResponse(this.calloutMockResult);
    }

    /**
     * BulkApiレスポンスMockクラス
     */
    public abstract class BulkApiResponseMock{

        public HttpResponse createResponse(Result mockResultEnum){

            HttpResponse res = new HttpResponse();

            if(Result.SUCCESS == mockResultEnum){
                res = respondAsSuccess();
            }
            else if(Result.FAILED == mockResultEnum){
                res = respondAsFailed();
            }

            return res;
        }

        //HTTPリクエスト検証
        public abstract void verifyHttpRequest(HttpRequest request);
        //API コールアウト成功Mock
        protected abstract HttpResponse respondAsSuccess();
        //API コールアウト失敗Mock
        protected abstract HttpResponse respondAsFailed();
    }

    /**
     * BulkApiジョブ作成Mock
     */
    public class JobCreateMock extends BulkApiResponseMock{

        public override void verifyHttpRequest(HttpRequest request){
            String endpoint = request.getEndpoint();
            System.assert(
                endpoint.endsWithIgnoreCase('job')
                ,'NG: 一括データ読み込みジョブ登録のエンドポイントが正しくない: ' + endpoint
            );
        }

        protected override HttpResponse respondAsSuccess(){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(201); // created
            res.setBody( getJobCreatedXml() );

            return res;
        }

        private String getJobCreatedXml(){
            XmlStreamWriter xmlWriter = new XmlStreamWriter();

            xmlWriter.writeStartDocument('UTF-8', '1.0');
            xmlWriter.writeEndDocument();

            xmlWriter.writeStartElement('', 'JobInfo', '');
            xmlWriter.writeAttribute('', '',  'xmlns', 'http://www.force.com/2009/06/asyncapi/dataload');

            xmlWriter.writeStartElement('', 'id', '');
            xmlWriter.writeCharacters(TEST_DUMMY_JOB_ID);
            xmlWriter.writeEndElement();

            xmlWriter.writeStartElement('', 'state', '');
            xmlWriter.writeCharacters('Open');
            xmlWriter.writeEndElement();

            xmlWriter.writeEndElement();

            String jobInfoXml = xmlWriter.getXmlString();

            xmlWriter.close();

            return jobInfoXml;
        }

        protected override HttpResponse respondAsFailed(){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(408); // Request Timeout

            return res;
        }
    }

    /**
     * BulkApiジョブ作成Mock
     */
    public class BatchCreateMock extends BulkApiResponseMock{

        public override void verifyHttpRequest(HTTPRequest request){
            String endpoint = request.getEndpoint();
            System.assert(
                ( endpoint.containsIgnoreCase('job')
                    && endpoint.containsIgnoreCase(TEST_DUMMY_JOB_ID)
                    && endpoint.endsWithIgnoreCase('batch')
                )
                ,'NG: バッチ登録のエンドポイントが正しくない: ' + endpoint
            );
        }

        protected override HttpResponse respondAsSuccess(){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(201); // created
            res.setBody( getBatchCreatedXml() );

            return res;
        }

        private String getBatchCreatedXml(){
            XmlStreamWriter xmlWriter = new XmlStreamWriter();

            xmlWriter.writeStartDocument('UTF-8', '1.0');
            xmlWriter.writeEndDocument();

            xmlWriter.writeStartElement('', 'JobInfo', '');
            xmlWriter.writeAttribute('', '',  'xmlns', 'http://www.force.com/2009/06/asyncapi/dataload');

            xmlWriter.writeStartElement('', 'id', '');
            xmlWriter.writeCharacters(TEST_DUMMY_BATCH_ID);
            xmlWriter.writeEndElement();

            xmlWriter.writeStartElement('', 'jobId', '');
            xmlWriter.writeCharacters(TEST_DUMMY_JOB_ID);
            xmlWriter.writeEndElement();

            xmlWriter.writeStartElement('', 'state', '');
            xmlWriter.writeCharacters('Queued');
            xmlWriter.writeEndElement();

            xmlWriter.writeEndElement();

            String jobInfoXml = xmlWriter.getXmlString();

            xmlWriter.close();

            return jobInfoXml;
        }

        protected override HttpResponse respondAsFailed(){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(408); // Request Timeout

            return res;
        }
    }

    /**
     * BulkApiジョブ終了Mock
     */
    public class JobCloseMock extends BulkApiResponseMock{

        public override void verifyHttpRequest(HTTPRequest request){
            String endpoint = request.getEndpoint();
            System.assert(
                endpoint.endsWithIgnoreCase(TEST_DUMMY_JOB_ID)
                ,'NG: 一括データ読み込みジョブ終了のエンドポイントが正しくない: ' + endpoint
            );
        }

        protected override HttpResponse respondAsSuccess(){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(202); // Accepted
            res.setBody( getJobClosedXml() );

            return res;
        }

        private String getJobClosedXml(){
            XmlStreamWriter xmlWriter = new XmlStreamWriter();

            xmlWriter.writeStartDocument('UTF-8', '1.0');
            xmlWriter.writeEndDocument();

            xmlWriter.writeStartElement('', 'JobInfo', '');
            xmlWriter.writeAttribute('', '',  'xmlns', 'http://www.force.com/2009/06/asyncapi/dataload');

            xmlWriter.writeStartElement('', 'id', '');
            xmlWriter.writeCharacters(TEST_DUMMY_JOB_ID);
            xmlWriter.writeEndElement();

            xmlWriter.writeStartElement('', 'state', '');
            xmlWriter.writeCharacters('Closed');
            xmlWriter.writeEndElement();

            xmlWriter.writeEndElement();

            String jobInfoXml = xmlWriter.getXmlString();

            xmlWriter.close();

            return jobInfoXml;
        }

        protected override HttpResponse respondAsFailed(){

            HttpResponse res = new HttpResponse();
            res.setStatusCode(408); // Request Timeout

            return res;
        }
    }

    private static final String TEST_DUMMY_JOB_ID = '750x00000000000000';
    private static final String TEST_DUMMY_BATCH_ID = '751x00000000000000';
}