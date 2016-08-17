package lf.media.core.data
{
	

	public class InitOption
	{
		
		public var appId                             :int     = 101;
		public var playerWidth                  :int          = 320;
		public var playerHeight                 :int          = 240;
		public var userAgent                      :String    = "";
		public var sdkVersion                    :String     = "";
		public var allowFullscreen            :Boolean = true;
		public var playerVersion               :String     = "v0.0.1";
		public var showHorn                     :Boolean = true;
		public var titles                               :Array     = ["超清","高清","标清"];;
		
		public var roomId                          :String     = "";
		/**roomType=  -1：iku  0:普通秀场  1：直播台 2：livehouse 3：theshow   4： 男神 女神    5：土豆最LIVE  */
		public var roomType                     :int           = 0;
		/**是否显示推荐 和片花 0:不显示  1：显示*/
		public var showPlugs                    :int = 0;
		public var showSwitchRoom       :Boolean = true;
		
		public function InitOption(configInfo:Object)
		{
			
			appId                       = configInfo["appId"]                  ==undefined ?  101 : int( configInfo["appId"] );
			roomId                    = configInfo["roomId"]                ==undefined ?  "0" : configInfo["roomId"];
			playerWidth           = configInfo["width"]                   ==undefined ?   320 : configInfo["width"];
			playerHeight           = configInfo["height"]                  ==undefined ?  240 : configInfo["height"];
			userAgent                = configInfo["userAgent"]            ==undefined ?  "" : configInfo["userAgent"];
			sdkVersion              = configInfo["sdkVersion"]  		   ==undefined ?  "v1" : configInfo["sdkVersion"];
			allowFullscreen       = configInfo["allowFullscreen"]==undefined ?  true : int(configInfo["allowFullscreen"])==1;
			showHorn                = configInfo["showHorn"]          == undefined? true : int(configInfo["showHorn"]) == 1;
			
			var debug :int         = configInfo["debug"]                  ==undefined ?  0 : int(configInfo["debug"]);
			
			if(configInfo["ex"] != undefined){
				
				roomType = configInfo["ex"]["roomType"]       ==undefined? 0: int(  configInfo["ex"]["roomType"]  );
				showPlugs = configInfo["ex"]["showPlugs"]      == undefined? 0 : int(configInfo["ex"]["showPlugs"]);
				var srFlag:int =  configInfo["ex"]["showSwitchRoom"]   == undefined? 0 : int(configInfo["ex"]["showSwitchRoom"]);
				showSwitchRoom =srFlag==1;
			}
			
			
		}
		
		
		public function get sessionId():String{
			
			if(_sessionId == ""){
				var date:Date = new Date();
				_sessionId   = date.getTime()+"";
				_sessionId += (date.getTime() * Math.random()).toFixed();
				_sessionId += (Math.random()*9999999).toFixed();
				
			}
			
			return _sessionId;
		}
		
		
		
		private var _sessionId:String = "";
		
		
		
	}
}