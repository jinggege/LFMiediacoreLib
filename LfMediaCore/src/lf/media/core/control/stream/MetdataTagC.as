package  lf.media.core.control.stream
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import lf.media.core.model.flv.MetdataTag;
	
	
	public class MetdataTagC
	{
		public function MetdataTagC()
		{
		}
		
		
		public function init(sourceB:URLStream,buffer:ByteArray):void{
			this._buffer = buffer;
			this._sourceB = sourceB;
		}
		
		
		
		/**0:是metdata 头   1:不是metdata头  2:数据不够*/
		public function get  isMetdata():int{
			
			if(_sourceB.bytesAvailable<_mt.headLen){
				return 2;
			}
			
			if(_buffer.bytesAvailable<_mt.headLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_mt.headLen-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			var str:String = "";
			var fStr:String =_buffer.readByte().toString(16);
			return fStr == "12"? 0:1;
		}
		
		
		public function get tagData():MetdataTag{
			var b:ByteArray = new ByteArray();
			_mt.size =  (_buffer[1] << 16) | (_buffer[2] << 8) | (_buffer[3]); 
			
			_buffer.position = 0;
			if(_buffer.bytesAvailable< _mt.tagLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_mt.tagLen-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			_buffer.readBytes(b,0,_buffer.bytesAvailable);
			_mt.data = b;
			_buffer.position = 0;
			//print();
			
			return _mt;
		}
		
		
		
		public function print():void{
			var str:String = "s data=";
			for(var i:int=0; i<10; i++){
				str += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str);
			
			var str1:String = "e data=";
			for(i=_buffer.length-10; i<_buffer.length; i++){
				str1 += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str1);
			
		}
		
		
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _mt:MetdataTag = new MetdataTag();
		
		
	}
}