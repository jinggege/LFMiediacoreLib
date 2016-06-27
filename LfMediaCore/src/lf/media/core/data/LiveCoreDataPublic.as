package lf.media.core.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import lf.media.core.component.loader.LFUrlLoader;
	import lf.media.core.event.LfEvent;
	import lf.media.core.util.Console;
	import lf.media.core.util.Util;
	
	/**
	 * 功能:
	 * 	     数据收集  派发核心
	 * 描述:
	 *       播放分为三步：
	 * 	      step1:获取调度地址    step2:通过调度地址获取播放地址   step3:用播放那个地址进行播放
	 * 
	 * Author:mj
	 */
	
	public class LiveCoreDataPublic extends EventDispatcher
	{
		/**get playlist url version*/
		public const GET_PLAYLIST_URL:String = "http://lapi.xiu.youku.com/v1/get_playlist";
		
		public const LFLIB_VERSION:String = "15.9.21";
		
		public var appId                :int          = 100;
		
		public var streamId          :String     = "";
		public var bps                   :String     = "400";
		public var dispatcherUrl  :String     = "";
		public var token                :String     = "98765"
		/**CDN 编号*/
		public var cdn                    :String     = "2";
		public var area_code         :String 	  = "";
		public var dma_code         :String     = "";
		public var isP2p                 :Boolean = false;
		public var sessionId          :String     = "";
		
		
		public function LiveCoreDataPublic()
		{
		}
		
		
		
		public function init(initOption:InitOption):void{
			_initOption = initOption;
		}
		
		
		public function play(playOption:PlayOption):void{
			_playOption           = playOption;
			_playOption.appId = _initOption["appId"];
			this.appId              = _playOption.appId;
			var date:Date = new Date();
			sessionId        =playOption.sessionId;
			
			var reqUrl:String = GET_PLAYLIST_URL
			reqUrl+= "?app_id=" + _playOption.appId;
			
			if(playOption.streamId==""){
				reqUrl+= "&alias=" + _playOption.alias;
			}else{
				reqUrl+="&stream_id=" + _playOption.streamId;
			}
			
			reqUrl+= "&token=" + _playOption.token;
			reqUrl+= "&player_type=" + "flash";
			reqUrl+= "&sdkversion=" + playOption.sdkversion;
			reqUrl+= "&playerversion=" + "3.1.0";
			Console.log("get play list=>",reqUrl);
			_requestTransit.request(reqUrl,3,responseTransit);
		}
		
		
		
		
		private function responseTransit(info:Object):void {
			var statusData:StatusData = new StatusData();
			
			switch(info["type"]){
				case Event.COMPLETE :
					parseTransitlist(info["data"].toString());
					return;
					
				case IOErrorEvent.IO_ERROR :
					statusData.type = StatusConfig.STATUS_ERROR;
					statusData.data = {logType:Config.LOG_TYPE_PLF,ec:ErrorCode.ERROR_1000}
					statusData.desc = "IOErrorEvent.IO_ERROR";
					notify(statusData);
					break;
				
				case SecurityErrorEvent.SECURITY_ERROR :
					statusData.type = StatusConfig.STATUS_ERROR;
					statusData.data = {logType:Config.LOG_TYPE_PLF,ec:ErrorCode.ERROR_1001}
					statusData.desc = "SecurityErrorEvent.SECURITY_ERROR";
					notify(statusData);
					break;
			}
			
		}
		
		
		
		private function parseTransitlist(jstr:String):void{
			_reqUseTime                        = _requestTransit.useTime;
			_httpCode                             = _requestTransit.httpCode;
			_tryCount                              = _requestTransit.tryCout;
			
			var validateVO:ValidateVO = Util.validateJson(jstr,"url_list","stream_id","url");
			var statusData:StatusData  = new StatusData();
			
			var respoenData:Object      = null;
			if(validateVO.isOk){
				respoenData     = validateVO.data;
				
				statusData.type = StatusConfig.STATUS_GET_URL_SUCCESS;
				statusData.data = StatusConfig.STATUS_STEP_1;
				statusData.desc = "获取调度地址成功 "
				notify(statusData);
				
			}else{
				statusData.type = StatusConfig.STATUS_ERROR;
				
				var errorCode:String = "";
				errorCode = ErrorCode.ERROR_1002;
				
				if(jstr !=""){
					var errValidate:ValidateVO = Util.validateJson(jstr,"error_code");
					if(errValidate.isOk){
						errorCode = errValidate.data["error_code"];
					}
				}
				statusData.data = {logType:Config.LOG_TYPE_PLF,ec:errorCode}
				statusData.desc = validateVO.data.toString();
				notify(statusData);
				return;
			}
			
			_transitList                 = respoenData["url_list"];
			
			_transitList.sort(compare);
			
			for(var i:int=0; i<_transitList.length;i++){
				if(_playOption.titles.length>i){
					_transitList[i]["title"]= _playOption.titles[i];
				}
					
			}
			
			_currQualityTiltle = getDefaultQualityTitle();
			statusData.type    = StatusConfig.STATUS_INIT_COMPLETE;
			statusData.data    = "";
			statusData.desc    = "StatusConfig.STATUS_INIT_COMPLETE";
			notify(statusData);
			
			requestPlayUrl(getTransitUrlByTitle(_currQualityTiltle));
		}
		
		
		public function getTransitlistLength():int{
			if(_transitList==null) return 0;
			return _transitList.length;
		}
		
		
		/**
		 * 
		 * 通过清晰度标题获取调度地址
		 */
		public function getTransitUrlByTitle(title:String):String{
			var avInfo:Object;
			for(var i:int=0; i<_transitList.length; i++)
			{
				avInfo = _transitList[i];
				if(title == avInfo["title"]){
					setStreamParam(avInfo);
					return avInfo["url"];
				}
			}
			
			return "";
		}
		
		
		
		private function setStreamParam(streamInfo:Object):void{
			this.streamId = streamInfo["stream_id"];
			this.bps = streamInfo["rt"];
			this.isP2p = Boolean(streamInfo["p2p"]);
		}
		
		
		private function compare(a:Object,b:Object):int{
			if(a["definition"] > b["definition"]){
				return 1;
			}else{
				return -1;
			}
			return 0;
		}
		
		
		/**
		 * 请求播放地址
		 */
		public function requestPlayUrl(url:String):void{
			Console.log("请求播放地址:"+url);
			_requestPlayurl.request(url,3,responseGetplayurl);
		}
		
		
		private function responseGetplayurl(info:Object):void{
			_reqUseTime                       = _requestPlayurl.useTime;
			_httpCode                            = _requestPlayurl.httpCode;
			_tryCount                            = _requestPlayurl.tryCout;
			
			var statusData:StatusData = new StatusData();
			Console.log("请求播放地址返回",info);
			switch(info["type"]){
				case Event.COMPLETE :
					parseGetplayurl(info["data"].toString());
					return;
					
				case IOErrorEvent.IO_ERROR :
					statusData.type = StatusConfig.STATUS_ERROR;
					statusData.data = {logType:Config.LOG_TYPE_RPF,ec:ErrorCode.ERROR_2000}
					statusData.desc = "IOErrorEvent.IO_ERROR!";
					notify(statusData);
					break;
				
				case SecurityErrorEvent.SECURITY_ERROR :
					statusData.type = StatusConfig.STATUS_ERROR;
					statusData.data = {logType:Config.LOG_TYPE_RPF,ec:ErrorCode.ERROR_2001}
					statusData.desc = "SecurityErrorEvent.SECURITY_ERROR!";
					notify(statusData);
					break;
			}
			
		}
		
		
		
		private function parseGetplayurl(jsonStr:String):void{
			
			var validateVO:ValidateVO = Util.validateJson(jsonStr,"u","stream_id","token");
			
			var statusData:StatusData = new StatusData();
			
			if(validateVO.isOk){
				_getPlayurlResult  = validateVO.data;
				
				this.cdn                  = _getPlayurlResult["s"].toString();
				this.token               = _getPlayurlResult["token"].toString();
				this.streamId         = _getPlayurlResult["stream_id"].toString();
				this.dispatcherUrl = _getPlayurlResult["dispatcher_url"].toString();
				this.dma_code       = _getPlayurlResult["dma"].toString();
				this.area_code       = _getPlayurlResult["ac"].toString();
				this.isP2p               =  Boolean(_getPlayurlResult["p2p"]);
				
				statusData.type = StatusConfig.STATUS_GET_URL_SUCCESS;
				statusData.data = StatusConfig.STATUS_STEP_2;
				statusData.desc = "获取播放地址成功 "
				
			}else{
				statusData.type = StatusConfig.STATUS_ERROR;
				statusData.data = {logType:Config.LOG_TYPE_RPF,ec:ErrorCode.ERROR_2002}
				statusData.desc =  validateVO.data.toString();
			}
			
			notify(statusData);
		}
		
		
		
		private function getDefaultQualityTitle():String{
			var dQuality:int = _playOption.defaultQuality>=_transitList.length? _transitList.length-1: _playOption.defaultQuality;
			var avInfo:Object = _transitList[dQuality];
			return avInfo["title"];
		}
		
		
		public function getStreamUrl():String{
			var url:String = _getPlayurlResult["u"];
			url += "&sid=" + sessionId;
			return url;
		}
		
		
		public function getCurrQualityTitle():String{
			return _currQualityTiltle;
		}
		
		
		public function switchQuality(title:String):void{
			_currQualityTiltle = title;
			_currTransitUrl    = getTransitUrlByTitle(title);
			requestPlayUrl(_currTransitUrl);
		}
		
		
		public function getTitles():Array{
			
			if(_transitList==null) return [];
			
			var arr:Array = [];
			var avInfo:Object;
			for(var i:int=0; i<_transitList.length; i++)
			{
				avInfo = _transitList[i];
				arr.push( avInfo["title"]);
			}
			return arr;
		}
		
		
		public function get playOption():PlayOption{
			return _playOption;
		}
		
		
		public function get requestUseTime():int{
			return _reqUseTime;
		}
		
		public function get requestHttpcode():int{
			return _httpCode;
		}
		
		
		public function get requestTryCount():int{
			return _tryCount;
		}
		
		
		public function get getStreamType():String{
			return this.isP2p? StatusConfig.STAEAM_TYPE_P2P : StatusConfig.STAEAM_TYPE_HTTP;
		}
		
		
		
		private function notify(data:StatusData):void{
			this.dispatchEvent(new LfEvent(data.type,data));
		}
		
		
		public function destroy():void{
			
			if(_requestTransit != null){
				_requestTransit.destroy();
				_requestTransit = null;
			}
			
			if(_requestPlayurl != null){
				_requestPlayurl.destroy();
				_requestPlayurl = null;
			}
			
			if(_transitList != null){
				while(_transitList.length){
					_transitList[0] = null;
					_transitList.splice(0,1);
				}
			}
			
			_transitList            = null;
			_getPlayurlResult =  null;
			_playOption           = null;
			_transitList            = null;
		}
		
		private var _playOption:PlayOption;
		private var _requestTransit:LFUrlLoader = new LFUrlLoader();
		private var _requestPlayurl:LFUrlLoader = new LFUrlLoader();
		private var _transitList:Array                     = null;
		private var _currQualityTiltle:String          = "";
		private var _getPlayurlResult:Object         = null;
		private var _currTransitUrl:String             = "";
		private var _reqUseTime:int                       =  0;     
		private var _httpCode:int                            = 0;
		private var _tryCount:int                             = 0;
		private var _initOption:InitOption              = null;           
		
		
		
	}
}