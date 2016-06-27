package lf.media.core.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import lf.media.core.data.LiveCoreData;
	import lf.media.core.data.PlayOption;
	import lf.media.core.data.StatusConfig;
	import lf.media.core.data.StatusData;
	import lf.media.core.event.LfEvent;
	import lf.media.core.video.CallbackType;
	import lf.media.core.video.ILfVideo;
	import lf.media.core.video.LfNomalVideo;
	
	public class LfCoreVideo extends Sprite
	{
		
		
		public function get version():String{
			return _lfCore.LFLIB_VERSION;
		}
		
		
		public function LfCoreVideo()
		{
			super();
		}
		
		
		public function play(playOption:PlayOption):void{
			
			destroy();
			
			_lfCore = new LiveCoreData();
			_lfCore.addEventListener(StatusConfig.STATUS_GET_URL_SUCCESS,getUrlComplete);
			_lfCore.addEventListener(StatusConfig.STATUS_ERROR,statusError);
			_lfCore.addEventListener(StatusConfig.STATUS_ROOM,liveStatus);
			_lfCore.addEventListener(StatusConfig.STATUS_INIT_COMPLETE,dataInitComplete);
			
			_lfCore.play(playOption);
		}
		
		
		
		private function getUrlComplete(event:LfEvent):void{
			
			clearVideo();
			
			var statusData:StatusData = event.data as StatusData;
			switch(int(statusData.data)){
				case StatusConfig.STATUS_STEP_1://请求调度地址完成
					break
				
				case StatusConfig.STATUS_STEP_2://请求播放地址完成
					_video              = new LfNomalVideo(videoCallback);
					_video.creat(null);
					_video.volume = volume;
					
					_video.netStream.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
					_video.play(_lfCore.getStreamUrl());
					_video.resize(_lfCore.playOption.playerWidth,_lfCore.playOption.playerHeight);
					addChild(_video as DisplayObject);
					break;
			}
		}
		
		
		
		
		public  function stop():void{
			if(_video==null) return;
			this.destroy();
		}
		
		public  function pause():void{
			if(_video==null) return;
			_video.pause();
		}
		
		public  function resume():void{
			if(_video==null) return;
			_video.resume();
		}
		
		public  function resize(width:int,height:int):void{
			if(_video==null) return;
			
			_width  = width;
			_height = height;
			
			/*
			var cW:int = 320;
			var cH:int = 240;
			
			
			if(_streamWidth > _streamHeight){
				if(_width/_height > _streamWidth/_streamHeight){
					cW  = _height * _streamWidth/_streamHeight;
					cH = _height;
				}else{
					cW  = _width;
					cH = _width *_streamHeight/_streamWidth;
				}
			}
			
			
			if(_streamWidth <= _streamHeight){
				cW  = _height * _streamWidth/_streamHeight;
				cH = _height;
			}
			
			_scaleNum = _width/cW;
			
			*/
			
			_video.resize(_width,_height);
		}
		
		
		public  function set volume(value:Number):void{
			_volume = value;
			
			if(_video != null){
				_video.volume = value;
			}
		}
		
		public  function get volume():Number{
			return _volume;
		}
		
		
		public function get netStream():NetStream{
			
			if(_video == null){
				return null;
			}
			return _video.netStream;
		}
		
		/**缩放比例*/
		public function get scaleNum():Number{
			return _scaleNum;
		}
		
		
		private function statusError(event:LfEvent):void{
			var statusData:StatusData = event.data as StatusData;
			this.dispatchEvent(new LfEvent(statusData.type,statusData));
		}
		
		
		private function liveStatus(event:LfEvent):void{
			var statusData:StatusData = event.data as StatusData;
			this.dispatchEvent(new LfEvent(statusData.type,statusData));
		}
		
		
		
		private function videoCallback(info:Object):void{
			
			if(info.callbackType == CallbackType.CT_ONMETADATA ){
				var statusData:StatusData = new StatusData();
				statusData.type = StatusConfig.STATUS_ONMETADATA
				statusData.data = info.data;
				statusData.desc = "medata info!";
				
				_streamWidth = statusData.data["width"]==null?  _streamWidth:statusData.data["width"];
				_streamHeight = statusData.data["height"]==null? _streamHeight:statusData.data["height"];
				resize(_width,_height);
				
				this.dispatchEvent(new LfEvent(StatusConfig.STATUS_STREAM,statusData));
				statusData = null;
			}
			
		}
		
		
		private function netStatusHandler(event:NetStatusEvent):void{
			var statusData:StatusData = new StatusData();
			statusData.type = StatusConfig.STATUS_STREAM
			statusData.data = event.info.code;
			this.dispatchEvent(new LfEvent(statusData.type,statusData) );
			statusData = null;
		}

		
		private function dataInitComplete(event:LfEvent):void{
			var statusData:StatusData = event.data as StatusData;
			this.dispatchEvent(new LfEvent(statusData.type,statusData));
		}
		
		
		public function getQualityTitles():Array{
			return _lfCore.getTitles();
		}
		
		
		public function getCurrQualityTitle():String{
			return _lfCore.getCurrQualityTitle();
		}
		
		public function switchQuality(qualityTitle:String):void{
			if(_lfCore == null) return;
			_lfCore.switchQuality(qualityTitle);
		}
		
		
		
		public function get p2p():Boolean{
			if(_lfCore == null) return false;
			return _lfCore.isP2p;
		}
		
		
		private function clearVideo():void{
			if(_video != null){
				
				if(_video.netStream != null){
					_video.netStream.removeEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
				}
				_video.destroy();
				if(this.contains(_video as DisplayObject)){
					this.removeChild(_video as DisplayObject);
				}
				_video = null;
			}
		}
		
		
		public function destroy():void{
			if(_lfCore != null){
				_lfCore.destroy();
				_lfCore.removeEventListener(StatusConfig.STATUS_GET_URL_SUCCESS,getUrlComplete);
				_lfCore.removeEventListener(StatusConfig.STATUS_ERROR,statusError);
				_lfCore.removeEventListener(StatusConfig.STATUS_ROOM,liveStatus);
				_lfCore.removeEventListener(StatusConfig.STATUS_INIT_COMPLETE,dataInitComplete);
			}
			_lfCore = null;
			
			clearVideo();
		}
		
		
		private var _video       :ILfVideo           =null;
		private var _lfCore      :LiveCoreData  =null;
		private var _volume    :Number           = 0.5;
		private var _width       :int                     = 400;
		private var _height      :int                     = 320;
		private var _scaleNum:Number           = 1;  
		private var _streamWidth:int               = 400;
		private var _streamHeight:int              = 320;
		
		
	}
}