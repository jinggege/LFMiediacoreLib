package  lf.media.core.util
{
	public class EnterframeTimerVO
	{
		
		public var loop:int = 0;  //0:执行次数不固定  1：执行1次
		
		/**
		 *  延迟时间,单位 ms
		 * 
		 * @param key:唯一标识
		 * @callback：回调函数
		 * @delay:延迟调用时间 单位 ms
		 * @loop:循环次数
		 */
		public function EnterframeTimerVO(key:String,callback:Function,delay:int,loop:int=0){
			
			this._key         = key;
			this._callback = callback;
			this._delay      = delay;
		}
		
		
		public function get key():String{
			return this._key;
		}
		
		public function get callback():Function{
			return this._callback;
		}
		
		public function get delay():int{
			return _delay;
		}
		
		
		public function set lastTime(value:Number):void{
			_lastTime = value;
		}
		
		public function get lastTime():Number{
			return _lastTime;
		}
		
		
		public function destroy():void{
			_callback = null;
		}
		
		
		
		
		
		private var _key:String;
		private var _callback:Function;
		private var _delay:int;
		private var _lastTime:Number = 0;
		
		
		
	}
}