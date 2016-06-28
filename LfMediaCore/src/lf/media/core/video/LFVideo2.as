package lf.media.core.video
{
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import lf.media.core.control.stream.LFStream;
	
	public class LFVideo2 extends Sprite implements ILfVideo
	{
		
		private const DEFAULT_WIDTH:int   = 320;
		private const DEFAULT_HEIGHT:int  = 240;
		
		public function LFVideo2(callback:Function)
		{
			_callback = callback;
			_lfStream = new LFStream();
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
			
			_netStartm = new NetStream(_conn);
			_netStartm.client = {onMetaData:onMetaData};
			_netStartm.bufferTime = 1;
			
			_netStartm.addEventListener(StatusEvent.STATUS,netStartHandler);
			_netStartm.addEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
			
			_lfStream.setNetStream( _netStartm);
			
			_creatComplete = true;
		}
		
		
		
		public function play(url:String):void
		{
			//try{
				_netStartm.play(null);
				_lfStream.reset();
				_lfStream.start(url);
				_video.attachNetStream(_netStartm);
			//}catch(err:Error){
				//trace();
			//}
			
		}
		
		public function pause():void
		{
			_netStartm.pause();
		}
		
		public function resume():void{
			
			if(_netStartm == null) return;
			_netStartm.resume();
		}
		
		public function stop():void
		{
		}
		
		public function set volume(value:Number):void
		{
			_sf.volume = value;
			if(_netStartm == null) return;
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
			return MediaType.VIDEO_NOMAL;
		}
		
		
		public function resize(width:int, height:int):void
		{
			if(_video==null) return;
			_video.width  = width;
			_video.height = height;
		}
		
		
		public function set setSmoothing(value:Boolean):void{
			if(_video==null) return;
			
			_video.smoothing = value;
		}
		
		
		protected function onMetaData(info:Object):void {
			_callback.call(null,new CallbackData(CallbackType.CT_ONMETADATA,info));
		}
		
		
		
		protected function netStartHandler(event:NetStatusEvent):void{				
			_callback.call(null,new CallbackData(event.info.code,event));
		}
		
		
		
		protected function ioerrorHandler(event:IOErrorEvent):void{
		}
		
		
		public function destroy():void
		{
			_creatComplete = false;
			
			
			if(_lfStream){
				_lfStream.destroy();
				_lfStream = null;
			}
			
			
			if(_conn != null){
				_conn.close();
				_conn = null;
			}
			
			
			if(_netStartm != null){
				_netStartm.removeEventListener(StatusEvent.STATUS,netStartHandler);
				_netStartm.close();
				_netStartm = null;
			}
			
			
			if(_video != null){
				if(this.contains(_video)){
					removeChild(_video);
					_video;
					_video = null;
				}
			}
			
			
		}
		
		private var _conn:NetConnection;
		private var _netStartm:NetStream;
		
		private var _sf:SoundTransform = new SoundTransform();
		
		private var _callback:Function;
		private var _video:Video;
		
		private var _creatComplete:Boolean = false;
		
		private var _lfStream:LFStream;
		
		
		
	}
}