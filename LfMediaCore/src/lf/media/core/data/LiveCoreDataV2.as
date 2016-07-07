package lf.media.core.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.getTimer;
	
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
	
	public class LiveCoreDataV2 extends EventDispatcher
	{
		/**get playlist url version*/
		public const GET_PLAYLIST_URL:String = "http://lapi.xiu.youku.com/v3/get_playlist";
		
		public const LFLIB_VERSION:String = "16.5.3";
		
		public var appId                :int          = 101;
		
		public var streamId          :String     = "";
		public var bps                   :String     = "400";
		public var dispatcherUrl  :String     = "";
		public var sessionId          :String     = "";
		
		
		public function LiveCoreDataV2()
		{
		}
		
		
		
		public function init(initOption:InitOption):void{
			_initOption = initOption;
		}
		
		/**拉去url 所用时间*/
		public function get pullurlTime():int{
			return _purlT;
		}
		
		
		public function play(playOption:PlayOption):void{
			_playOption           = playOption;
			_playOption.appId = _initOption["appId"];
			this.appId              = _playOption.appId;
			sessionId                =playOption.sessionId;
			
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
			reqUrl+= "&playerversion=" + "3.2.0";
			Console.log("get play list=>",reqUrl);
			_purlT = new Date().getTime();
			_reqGetplayList.request(reqUrl,3,respGetplaylist);
		}
		
		
		
		private function respGetplaylist(info:Object):void {
			_purlT = new Date().getTime() - _purlT;
			
			var statusData:StatusData = new StatusData();
			
			switch(info["type"]){
				case Event.COMPLETE :
					parsePlaylist(info["data"].toString());
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
		
		
		
		private function parsePlaylist(jstr:String):void{
			_reqUseTime                        = _reqGetplayList.useTime;
			_httpCode                             = _reqGetplayList.httpCode;
			_tryCount                              = _reqGetplayList.tryCout;
			
			var validateVO:ValidateVO = Util.validateJson(jstr,"url_list","stream_id","url");
			var statusData:StatusData  = new StatusData();
			
			var respoenData:Object      = null;
			if(validateVO.isOk){
				respoenData     = validateVO.data;
				
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
			
			_playList                 = respoenData["url_list"];
			
			_playList.sort(compare);
			
			for(var i:int=0; i<_playList.length;i++){
				if(_playOption.titles.length>i){
					_playList[i]["title"]= _playOption.titles[i];
				}
			}
			
			_currQualityTiltle = getDefaultQualityTitle();
			parsePlayInfo(getPlayInfoUrlByTitle(_currQualityTiltle));
		}
		
		
		public function getPlayListLength():int{
			if(_playList==null) return 0;
			return _playList.length;
		}
		
		
		/**
		 * 通过清晰度标题获取调度地址
		 */
		public function getPlayInfoUrlByTitle(title:String):Object{
			var avInfo:Object;
			for(var i:int=0; i<_playList.length; i++)
			{
				avInfo = _playList[i];
				if(title == avInfo["title"]){
					return avInfo;
				}
			}
			
			return null;
		}
		
		
		
		private function compare(a:Object,b:Object):int{
			if(a["definition"] > b["definition"]){
				return 1;
			}else{
				return -1;
			}
			return 0;
		}
		
		
		
		private function parsePlayInfo(playInfo:Object):void{
			var statusData:StatusData = new StatusData();
				_getPlayurlResult  = playInfo;
				this.streamId         = _getPlayurlResult["stream_id"].toString();
				this.bps 					=  _getPlayurlResult["rt"].toString();
				
				statusData.type = StatusConfig.STATUS_GET_URL_SUCCESS;
				statusData.data = StatusConfig.STATUS_STEP_2;
				statusData.desc = "获取播放地址成功 "
			
				notify(statusData);
		}
		
		
		
		private function getDefaultQualityTitle():String{
			var dQuality:int = _playOption.defaultQuality>=_playList.length? _playList.length-1: _playOption.defaultQuality;
			var avInfo:Object = _playList[dQuality];
			return avInfo["title"];
		}
		
		
		public function getStreamUrl():String{
			var url:String = _getPlayurlResult["url"];
			url += "&sid=" + sessionId;
			return url;
		}
		
		
		public function getCurrQualityTitle():String{
			return _currQualityTiltle;
		}
		
		
		public function switchQuality(title:String):void{
			_currQualityTiltle = title;
			parsePlayInfo(getPlayInfoUrlByTitle(title));
		}
		
		
		public function getTitles():Array{
			
			if(_playList==null) return [];
			
			var arr:Array = [];
			var avInfo:Object;
			for(var i:int=0; i<_playList.length; i++)
			{
				avInfo = _playList[i];
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
		
		
		
		
		private function notify(data:StatusData):void{
			this.dispatchEvent(new LfEvent(data.type,data));
		}
		
		
		public function destroy():void{
			
			if(_reqGetplayList != null){
				_reqGetplayList.destroy();
				_reqGetplayList = null;
			}
			
			if(_requestPlayurl != null){
				_requestPlayurl.destroy();
				_requestPlayurl = null;
			}
			
			if(_playList != null){
				while(_playList.length){
					_playList[0] = null;
					_playList.splice(0,1);
				}
			}
			
			_playList            = null;
			_getPlayurlResult =  null;
			_playOption           = null;
			_playList            = null;
		}
		
		private var _playOption:PlayOption;
		private var _reqGetplayList:LFUrlLoader = new LFUrlLoader();
		private var _requestPlayurl:LFUrlLoader = new LFUrlLoader();
		private var _playList:Array                     = null;
		private var _currQualityTiltle:String          = "";
		private var _getPlayurlResult:Object         = null;
		private var _reqUseTime:int                       =  0;     
		private var _httpCode:int                            = 0;
		private var _tryCount:int                             = 0;
		private var _initOption:InitOption              = null;           
		/**拉取play url 所用时间*/
		private var _purlT:int = 0;
		
		
		
	}
}