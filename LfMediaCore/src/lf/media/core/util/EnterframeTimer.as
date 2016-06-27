package  lf.media.core.util
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	
	/**********************************************************
	 * EnterframeTimer
	 * 
	 * Author : mj
	 * Description:
	 *  		用Enterframe + callback 的方式取代  Timer
	 * 
	 ***********************************************************/
	
	public class EnterframeTimer extends EventDispatcher
	{
		
		public function EnterframeTimer(target:IEventDispatcher=null)
		{
			super(target);
			
		}
		
		
		public function start(stage:Stage):void{
			_callbackList = new Vector.<EnterframeTimerVO>();
			stage.addEventListener(Event.ENTER_FRAME,enterframeHandler);
		}
		
		
		public function addListener(enterFVO:EnterframeTimerVO):void{
			enterFVO.lastTime = getTimer();
			var has:Boolean = false;
			
			for(var i:int = 0; i<_callbackList.length; i++){
				if(_callbackList[i].key == enterFVO.key){
					has = true;
					break;
				}
			}
			
			if(!has){
				_callbackList.push(enterFVO);
			}else{
				//todo  enterFVO.key+" 被重复注册!
			}
				
		}
		
		
		private var _targetEVO:EnterframeTimerVO;
		private function enterframeHandler(event:Event):void{
			for(var i:int = 0; i<_callbackList.length; i++){
				_targetEVO = _callbackList[i];
				if(getTimer() - _targetEVO.lastTime>= _targetEVO.delay){
					_targetEVO.callback.call();
					_targetEVO.lastTime = getTimer();
				}
			}
		}
		
		
		
		public function hasListener(key:String):Boolean{
			var etVO:EnterframeTimerVO;
			for(var i:int = 0; i<_callbackList.length; i++){
				etVO = _callbackList[i];
				if(key== etVO.key){
					return true;
				}
			}
			
			return false;
		}
		
		
		
		public function remove(key:String):void{
			
			for(var i:int=0; i<_callbackList.length; i++){
				if(key == _callbackList[i].key){
					_callbackList[i].destroy();
					_callbackList[i] = null;
					_callbackList.splice(i,1);
					return;
				}
			}
		
		}
		
		
		
		
		
		public static function get get():EnterframeTimer{
			
			_instance = _instance==null? new EnterframeTimer() : _instance;
			return _instance;
		}
		
		
		
		private var _callbackList:Vector.<EnterframeTimerVO>;
		private static var _instance:EnterframeTimer;
		
		
		
		
	}
}