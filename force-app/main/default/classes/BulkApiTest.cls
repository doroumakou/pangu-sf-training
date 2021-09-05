@isTest
private class BulkApiTest {

    @isTest static void test001_CreateBulkDataLoadJob_Success() {
        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCreateMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        Test.startTest();

        String errMsg = '';
        Id jobId = null;
        try{
            BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );

            jobId = bulkOperation.createBulkDataLoadJob('Account', BulkApi.Op.DML_DELETE);

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        Test.stopTest();

        System.assert(
            String.isBlank(errMsg)
            ,'NG: 一括データ読み込みジョブ登録時エラーが発生した: ' + errMsg
        );
    }

    @isTest static void test002_CreateBulkDataLoadJob_Failed() {
        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCreateMock()
                ,BulkApiCalloutMock.Result.FAILED
            )
        );

        Test.startTest();

        String errMsg = '';
        Id jobId = null;
        try{
            BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );

            jobId = bulkOperation.createBulkDataLoadJob('Account', BulkApi.Op.DML_INSERT);

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        Test.stopTest();

        System.assert(
            errMsg.containsIgnoreCase(BulkApi.MSG_ERR_FAILED_TO_CREATE_JOB)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );

        System.assert(
            String.isBlank(jobId)
            ,'NG: エラー発生したのにjobIdが取得出来た: ' + jobId
        );
    }

    @isTest static void test003_CreateBulkDataLoadJob_NoSessionId() {

        String errMsg = '';
        try{
            BulkApi bulkOperation = new BulkApi(null);
        }catch(BulkApi.NoSessionIdException bulkApiErr){
            errMsg = bulkApiErr.getMessage();
        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        System.assert(
            errMsg.containsIgnoreCase(BulkApi.MSG_ERR_BLANK_SESSION_ID)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }

    @isTest static void test004_UpdateRecords_Success() {

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCreateMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );

        Id jobId = bulkOperation.createBulkDataLoadJob('Account', BulkApi.Op.DML_UPDATE);

        Test.startTest();

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.BatchCreateMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        String errMsg = '';
        try{

            bulkOperation.updateRecords( jobId, new List<Sobject>() );

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        Test.stopTest();

        System.assert(
            String.isBlank(errMsg)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }

    @isTest static void test005_UpdateRecords_Failed() {

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCreateMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );

        Id jobId = bulkOperation.createBulkDataLoadJob('Account', BulkApi.Op.DML_UPDATE);

        Test.startTest();

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.BatchCreateMock()
                ,BulkApiCalloutMock.Result.FAILED
            )
        );

        String errMsg = '';
        try{

            bulkOperation.updateRecords( jobId, new List<Sobject>() );

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        Test.stopTest();

        System.assert(
            errMsg.containsIgnoreCase(BulkApi.MSG_ERR_BATCH_FAILED)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }

    @isTest static void test006_CloseBulkDataLoadJob_Success() {

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCreateMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );

        Id jobId = bulkOperation.createBulkDataLoadJob('Account', BulkApi.Op.DML_UPDATE);

        Test.startTest();

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCloseMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        String errMsg = '';
        try{

            bulkOperation.closeBulkDataLoadJob(jobId);

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        Test.stopTest();

        System.assert(
            String.isBlank(errMsg)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }

    @isTest static void test007_CloseBulkDataLoadJob_Failed() {

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCreateMock()
                ,BulkApiCalloutMock.Result.SUCCESS
            )
        );

        BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );

        Id jobId = bulkOperation.createBulkDataLoadJob('Account', BulkApi.Op.DML_UPDATE);

        Test.startTest();

        Test.setMock(
            HttpCalloutMock.class
            ,new BulkApiCalloutMock(
                new BulkApiCalloutMock.JobCloseMock()
                ,BulkApiCalloutMock.Result.FAILED
            )
        );

        String errMsg = '';
        try{

            bulkOperation.closeBulkDataLoadJob(jobId);

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        Test.stopTest();

        System.assert(
            errMsg.containsIgnoreCase(BulkApi.MSG_ERR_FAILED_TO_CLOSE_JOB)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }

    @isTest static void test008_UpdateRecords_NoJobId() {

        String errMsg = '';
        try{
            BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );
            bulkOperation.updateRecords( null, new List<Account>() );

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        System.assert(
            errMsg.containsIgnoreCase(BulkApi.MSG_ERR_BLANK_JOB_ID)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }

    @isTest static void test009_CloseBulkDataLoadJob_NoJobId() {

        String errMsg = '';
        try{
            BulkApi bulkOperation = new BulkApi( UserInfo.getSessionId() );
            bulkOperation.closeBulkDataLoadJob(null);

        }catch(System.Exception e){
            errMsg = e.getMessage();
        }

        System.assert(
            errMsg.containsIgnoreCase(BulkApi.MSG_ERR_BLANK_JOB_ID)
            ,'NG: 予期せぬエラーが発生しました: ' + errMsg
        );
    }
}