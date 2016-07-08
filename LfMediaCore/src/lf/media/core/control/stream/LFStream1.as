package lf.media.core.control.stream
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import lf.media.core.model.flv.AudioTag;
	import lf.media.core.model.flv.HeadTag;
	import lf.media.core.model.flv.MetdataTag;
	import lf.media.core.model.flv.VideoTag;
	
	
	public class LFStream1 extends EventDispatcher
	{
		/**事件:IO 错误*/
		public static const E_ERR_IO:String=  "E_ERR_IO";
		/**事件:安全沙箱 错误*/
		public static const E_ERR_SECURITY:String = "E_ERR_SECURITY";
		/**事件:下载流结束*/
		public static const E_STREAM_COMPLETE:String = "E_STREAM_COMPLETE";
		/**事件:下载流进行中*/
		public static const E_STREAM_PROGRESS:String = "E_STREAM_PROGRESS";
		
		
		private const ClearCatchLimitSize:int = 20000;
		private const MAX_LEN:int = 2.5;  //7  最优
		
		private const firstRead:int = 1;
		
		private var _tiker:Timer = new Timer(0);
		private var _delayT:Timer = new Timer(0);
		private var _restartT:Timer = new Timer(2000);
		
		public function LFStream1(target:IEventDispatcher=null)
		{
			super(target);
			_urlStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			_urlStream.addEventListener(Event.COMPLETE,completeHandler);
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
			_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityerrorHandler);
			_tiker.addEventListener(TimerEvent.TIMER,rendHandler);
			_delayT.addEventListener(TimerEvent.TIMER,checkDelayHandler);
			_restartT.addEventListener(TimerEvent.TIMER,restartCheckHandler);
		}
		
		public function start(url:String):void{
			var d:Date = new Date();
			_pt = 0;
			_url = url;
			_headTime =new Date().getTime();
			_urlStream.load(new URLRequest(url))
			_tiker.start();
			_delayT.start();
			_restartT.start();
		}
		
		
		public function reStart(url:String):void{
			this.reset();
			_urlStream.load(new URLRequest(url))
			_tiker.start();
			_delayT.start();
			_restartT.start();
		}
		
		
		public function setNetStream(netStream:NetStream):void{
			_netStream = netStream;
		}
		
		public function get totalBty():Number{
			return _urlStream.bytesAvailable;
		}
		
		/**从发出请求 到拉到数据所用时间 (单位:ms)*/
		public function get pullStreamTime():int{
			return _pt;
		}
		
		
		private var _pt:int = 0;
		private function progressHandler(event:ProgressEvent):void{
			if(_pt==0){
				_pt = new Date().getTime() - _headTime;
			}
			
			var b:ByteArray = new ByteArray();
			_urlStream.readBytes(b,0,_urlStream.bytesAvailable);
			_netStream.appendBytes(b);
			b.clear();
			b=null;
			
			
		}
		
		
		private function completeHandler(event:Event):void{
			this.dispatchEvent(new Event(E_STREAM_COMPLETE));
		}
		
		
		private function ioerrorHandler(event:ErrorEvent):void{
			this.dispatchEvent(new Event(E_ERR_IO));
		}
		
		private function securityerrorHandler(event:SecurityErrorEvent):void{
			this.dispatchEvent(new Event(E_ERR_SECURITY));
		}
		
		
		private var _delay:Number = 0;
		private var _cc:int = 0;
		private function checkDelayHandler(event:TimerEvent):void{
			_delay = _delay==0? getTimer() : _delay;
			_cc = getTimer() - _delay;
			_delay = getTimer();
			
		}
		
		
		private var _bec:int = 0;
		private function restartCheckHandler(event:TimerEvent):void{
			if(_netStream.bufferLength < 0.1){
				
				if(_bec>5){
					reStart(_url);
					_bec = 0;
				}
				
				_bec++;
			}else{
				_bec = 0;
			}
			
			
			
			if(_netStream.bufferLength>10){
				_netStream.seek(_netStream.time+0.5);
			}
		}
		
		
		private function rendHandler(event:TimerEvent):void{
			if(_netStream == null) return;
			
			if(_netStream.bufferLength > MAX_LEN){
				_netStream.bufferTimeMax = 2;
			}
			
			/*
			var t:int = _cc>50? 40:2;
			while(t>0){
				var b:ByteArray = new ByteArray();
				_urlStream.readBytes(b,0,_urlStream.bytesAvailable);
				_netStream.appendBytes(b);
				b.clear();
				b=null;
				t--;
			}
			*/
		}
		
		
		private function appendFlvHead():void{
			var headFlag:int = _flvHeadC.isFlvHead;
			if(headFlag==0){
				var ht:HeadTag = _flvHeadC.tagData;
				_netStream.appendBytes(ht.data);
				ht.destroy();
				_buffer.clear();
				ht = null;
			}
		}
		
		
		private function appendMetdata():void{
			var mFlag:int = _metdataC.isMetdata;
			if(mFlag==0){
				var mt:MetdataTag = _metdataC.tagData;
				_netStream.appendBytes(mt.data);
				mt.destroy();
				_buffer.clear();
				mt = null;
			}
		}
		
		private function appendAudioTag():int{
			var aFlag:int = _audioTagC.isAudio;
			if(aFlag==0){
				var at:AudioTag = _audioTagC.tagData;
				if( at.data){
					_netStream.appendBytes(at.data);
					at.destroy();
					_buffer.clear();
				}
				at = null;
			}
			
			return aFlag;
		}
		
		
		private function appendVideoTag():int{
			var vFlag:int = _videoTagC.isVideo;
			if(vFlag==0){
				var vt:VideoTag = _videoTagC.tagData;
				if(vt.data){
					_netStream.appendBytes(vt.data);
					vt.destroy();
					vt = null;
					_buffer.clear();
				}
				
			}
			
			return vFlag;
		}
		
		private function appendKeyVideoTag():void{
			var vFlag:int = _videoTagC.isVideo;
			if(vFlag==0){
				var vt:VideoTag = _videoTagC.tagData;
				//vt.print();
				if(vt.data){
					if(vt.keyType==0x17){
						_netStream.appendBytes(vt.data);
					}
					vt.destroy();
					vt = null;
					_buffer.clear();
				}
			}
		}
		
		private function clearAudioCatch():void{
			var aFlag:int = _audioTagC.isAudio;
			if(aFlag==0){
				var at:AudioTag = _audioTagC.tagData;
				if( at.data){
					at.destroy();
					_buffer.clear();
				}
				
				at = null;
			}
		}
		
		
		/**
		 * 清除视频缓冲 ：只清除普通帧
		 */
		private function clearVideoCatch():void{
			var vFlag:int = _videoTagC.isVideo;
			if(vFlag==0){
				var vt:VideoTag = _videoTagC.tagData;
				if(vt.data){
					if(vt.keyType==0x27){
						_netStream.appendBytes(vt.data);
					}
					vt.destroy();
					_buffer.clear();
				}
				vt = null;
			}
		}
		
		
		/**
		 * 清除坏包
		 */
		private function clearBadTag():void{
			
			trace("xxxxxxxxxx 脏数据");
			var index:int = 0;
			while(index<_buffer.length){
				_buffer.position = index;
				
				if(_buffer.readByte()==0x09){
					
					if(index+11 >_buffer.length){
						_urlStream.readBytes(_buffer,_buffer.length,(index+11-_buffer.length+1));
					}
					
					var frameType:uint = 0;
					_buffer.position = index+11;
					frameType = _buffer.readByte();
					_buffer.position = index;
					
					if(frameType==0x17 || frameType==0x27){
						var b:ByteArray = new ByteArray();
						_buffer.position = index;
						//_buffer.readBytes(b,0,_buffer.length-index);
						_buffer.readBytes(b,0,_buffer.bytesAvailable);
						_buffer.clear();
						b.position = 0;
						b.readBytes(_buffer,0,b.bytesAvailable);
						b.clear();
						b = null;
						return;
					}
				}
				
				index++;
				
			}
			
		}
		
		
		private function inCatch(readLen:int):void{
			if(_urlStream.bytesAvailable<firstRead ) return;
			if(_buffer.bytesAvailable==0){
				_urlStream.readBytes(_buffer,0,readLen);
			}
		}
		
		
		
		public function reset():void{
			_tiker.stop();
			_delayT.stop();
			_buffer.clear();
			if(_urlStream.connected){
				_urlStream.close();
			}
		}
		
		
		
		public function destroy():void{
			
			if(_tiker){
				_tiker.stop();
				_tiker = null;
			}
			
			if(_buffer){
				_buffer.clear();
				_buffer = null;
			}
			
			if(_urlStream){
				_urlStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
				_urlStream.removeEventListener(Event.COMPLETE,completeHandler);
				_urlStream.removeEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
				_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityerrorHandler);
			}
			
		}
		
		
		
		private var _urlStream:URLStream = new URLStream();
		private var _buffer:ByteArray = new ByteArray();
		private var _netStream:NetStream;
		private var _readEnd:Boolean = false;
		private var _flvHeadC:FlvHeadTagC = new FlvHeadTagC();
		private var _metdataC:MetdataTagC = new MetdataTagC();
		private var _audioTagC:AudioTagC = new AudioTagC();
		private var _videoTagC:VideoTagC = new VideoTagC();
		private var _sourceB:ByteArray = new ByteArray();
		private var _url:String = "";
		private var _headTime:int  = 0;
		
		
		
	}
}