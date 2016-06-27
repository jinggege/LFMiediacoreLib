package lf.media.core.video
{
	import com.youku.player.YoukuStream;
	import com.youku.player.YoukuStreamConfig;
	import com.youku.player.YoukuStreamEvent;
	
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class LfP2pVideo extends Sprite implements ILfVideo
	{
		
		private const DEFAULT_WIDTH:int   = 320;
		private const DEFAULT_HEIGHT:int  = 240;
		
		public function LfP2pVideo(callback:Function)
		{
			_callback = callback;
			super();
		}
		
		
		public function creat(config:Object = null):void{
			
			if(_creatComplete){
				destroy();
			}
			
			_video = new Video();
			this.resize(DEFAULT_WIDTH,DEFAULT_HEIGHT);
			addChild(_video);
			
			_conn = new NetConnection();
			_conn.connect(null);
			
			var p2pConfig:YoukuStreamConfig = new YoukuStreamConfig();
			
			p2pConfig["channel_id"]               = config["channel_id"]
			p2pConfig["area_code"]                 = config["area_code"]
			p2pConfig["dma_code"]                 = config["dma_code"]
			p2pConfig["session_id"]                 = config["session_id"]
			p2pConfig["token"]                         = config["token"]
			p2pConfig["addrDispatcherUrl"] = config["addrDispatcherUrl"];
			p2pConfig["bps"]                              = config["bps"];
			p2pConfig["debug"]                         = config["debug"];
			
			
			_netStartm = new YoukuStream(_conn,p2pConfig)
			_netStartm.client = {onMetaData:onMetaData};
			
			_netStartm.addEventListener(StatusEvent.STATUS,netStartHandler);
			
			_netStartm.addEventListener(YoukuStreamEvent.DOWNLOAD_DATA_SECURITY_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.DOWNLOAD_DATA_IO_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.DOWNLOAD_DATA_SECURITY_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.DOWNLOAD_DATA_TIMEOUT_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.META_DATA_DATA_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.META_DATA_IO_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.META_DATA_SECURITY_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.META_DATA_TIMEOUT_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.SERVER_HOST_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.START_DATA_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.TIME_RANGE_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.TIME_RANGE_HTTP_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.TIME_RANGE_IO_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.TIME_RANGE_SECURITY_ERROR,p2pErrorHandler);
			_netStartm.addEventListener(YoukuStreamEvent.TIME_RANGE_TIMEOUT_ERROR,p2pErrorHandler);
			
			_creatComplete = true;
		}
		
		
		
		public function play(url:String):void
		{
			_netStartm.play(url);
			_video.attachNetStream(_netStartm);
		}
		
		public function pause():void
		{
		}
		
		public function resume():void{
		
		}
		
		public function stop():void
		{
		}
		
		public function set volume(value:Number):void
		{
			_sf.volume = value;
			_netStartm.soundTransform = _sf;
		}
		
		public function get volume():Number
		{
			return _sf.volume;
		}
		
		
		public function get netStream():NetStream{
			return _netStartm;
		}
		
		
		
		public function get mediaType():String{
			return MediaType.VIDEO_P2P;
		}
		
		
		public function resize(width:int, height:int):void
		{
			
			_video.width  = width;
			_video.height = height;
		}
		
		
		
		public function set setSmoothing(value:Boolean):void{
			_video.smoothing = value;
		}
		
		
		
		protected function onMetaData(info:Object):void {
			_callback.call(null,new CallbackData(CallbackType.CT_ONMETADATA,info));
		}
		
		
		
		protected function netStartHandler(event:NetStatusEvent):void{				
			_callback.call(null,new CallbackData(event.info.code,event));
		}
		
		
		private function p2pErrorHandler(event:YoukuStreamEvent):void{
			
			_callback.call(null,new CallbackData(CallbackType.CT_P2P_LIB_ERR,event));
		}
		
		
		
		public function getPeerStatus():String{
			return _netStartm.getPeerStatus();
		}
		
		public function getPlayStatus():String{
			return _netStartm.getPlayStatus();
		}
		
		public function getCloseDelayTime():int{
			return _netStartm.getCloseDelayTime();
		}
		
		public function getLocalConnectionId():String{
			return _netStartm.getLocalConnectionId();
		}
		
		
		public function getCurrPlayIdSwitchClarity():uint{
			return _netStartm.getCurrPlayIdSwitchClarity();
		}
			
		
		
		
		
		public function destroy():void
		{
			_creatComplete = false;
			
			if(_conn != null){
				_conn.close();
				_conn = null;
			}
			
			
			if(_netStartm != null){
				_netStartm.removeEventListener(StatusEvent.STATUS,netStartHandler);
				
				_netStartm.removeEventListener(YoukuStreamEvent.DOWNLOAD_DATA_SECURITY_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.DOWNLOAD_DATA_IO_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.DOWNLOAD_DATA_SECURITY_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.DOWNLOAD_DATA_TIMEOUT_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.META_DATA_DATA_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.META_DATA_IO_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.META_DATA_SECURITY_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.META_DATA_TIMEOUT_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.SERVER_HOST_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.START_DATA_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.START_DATA_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.TIME_RANGE_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.TIME_RANGE_HTTP_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.TIME_RANGE_IO_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.TIME_RANGE_SECURITY_ERROR,p2pErrorHandler);
				_netStartm.removeEventListener(YoukuStreamEvent.TIME_RANGE_TIMEOUT_ERROR,p2pErrorHandler);
				
				_netStartm.close();
				_netStartm = null;
			}
			
			if(_video==null) return;
			if(this.contains(_video)){
				removeChild(_video);
				_video = null;
			}
			
		}
		
		private var _conn:NetConnection;
		private var _netStartm:YoukuStream;
		
		private var _sf:SoundTransform = new SoundTransform();
		
		private var _callback:Function;
		private var _video:Video;
		
		private var _creatComplete:Boolean = false;
		
		
		
	}
}