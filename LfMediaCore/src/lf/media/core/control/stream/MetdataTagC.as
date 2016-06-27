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
		
		
		
		public function get  isMetdata():Boolean{
			var str:String = "";
			if(_buffer.bytesAvailable<_mt.headLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_mt.headLen-_buffer.bytesAvailable);
			}
			var fStr:String = _buffer[0].toString(16);
			return fStr == "12";
		}
		
		
		public function get tagData():MetdataTag{
			var b:ByteArray = new ByteArray();
			
			var s:String = "";
			s += _buffer[1].toString(16);
			s += _buffer[2].toString(16);
			s += _buffer[3].toString(16);
			_mt.size = parseInt(s,16);
			
			if(_buffer.bytesAvailable< _mt.tagLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_mt.tagLen-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			_buffer.readBytes(b,0,_mt.tagLen);
			_mt.data = b;
			_buffer.position = _mt.tagLen;
			return _mt;
		}
		
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _mt:MetdataTag = new MetdataTag();
		
		
	}
}