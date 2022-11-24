module top;

virtual class shape;
    protected real length;
    protected real width;

    function new(real w, real l);
        length = l;
        width = w;    
    endfunction : new

    pure virtual function real get_area();

    pure virtual function void print();

endclass : shape

class rectangle extends shape;
    function new(real w, real l);
        super.new(.w(w), .l(l));   
    endfunction : new

    function real get_area();
        return width*length;
    endfunction

    function void print();
        $display("Rectangle w=%g h=%g area=%g", super.width, super.length, get_area());
    endfunction
endclass : rectangle

class square extends shape;
    function new(real w);
        super.new(.w(w), .l(w));   
    endfunction : new

    function real get_area();
        return width*width;
    endfunction : get_area

    function void print();
        $display("Square w=%g area=%g", super.width, get_area());
    endfunction
endclass : square

class triangle extends shape;
    function new(real w, real l);
        super.new(.w(w), .l(l));   
    endfunction : new

    function real get_area();
        return (width*length)/2;
    endfunction : get_area

    function void print();
        $display("Triangle w=%g h=%g area=%g", super.width, super.length, get_area());
    endfunction
endclass : triangle


class shape_factory;
    static function shape make_shape(string shape_type, real w, real h);
    rectangle rectangle_h;
    square square_h;
    triangle triangle_h;
    case(shape_type)
        "rectangle": begin
            rectangle_h = new(w, h);
            return rectangle_h;
        end
        "square": begin
            square_h = new(w);
            return square_h;
        end
        "triangle": begin
            triangle_h = new(w, h);
            return triangle_h;
        end
        default: begin
            $fatal (1, {"No such shape: ", shape_type});
        end
    endcase
    endfunction : make_shape
endclass : shape_factory


class shape_reporter #(parameter type T = rectangle);
    protected static T shape_storage[$];
	
	static function void push_shape_to_storage(T sh);
		shape_storage.push_back(sh);
	endfunction : push_shape_to_storage

    static function void report_shapes();
        real total_area = 0;
        foreach(shape_storage[i])
        begin
            shape_storage[i].print();
            total_area = total_area + shape_storage[i].get_area();
        end
        $display("Total area = %g", total_area);
    endfunction : report_shapes
endclass : shape_reporter


initial begin
    shape shape_h;
    rectangle rectangle_h;
    square square_h;
    triangle triangle_h;

    bit cast_ok;
    int fd;
    string sh;
    real w;
    real l;

    fd = $fopen("lab04part1_shapes.txt", "r");
    while($fscanf(fd, "%s %g %g", sh, w, l) == 3)
    begin
        shape_h = shape_factory::make_shape(sh, w, l);
        case(sh) 
            "rectangle": begin
                cast_ok = $cast(rectangle_h, shape_h);
                if ( ! cast_ok) 
                    $fatal(1, "Failed to cast shape_h to rectangle_h");
                shape_reporter#(rectangle)::push_shape_to_storage(rectangle_h);
            end
            "square": begin
                cast_ok = $cast(square_h, shape_h);
                if ( ! cast_ok) 
                    $fatal(1, "Failed to cast shape_h to square_h");
                shape_reporter#(square)::push_shape_to_storage(square_h);
            end
            "triangle": begin
                cast_ok = $cast(triangle_h, shape_h);
                if ( ! cast_ok) 
                    $fatal(1, "Failed to cast shape_h to square_h");
                shape_reporter#(triangle)::push_shape_to_storage(triangle_h);
            end
        endcase
    end
    $fclose(fd);

    shape_reporter#(rectangle)::report_shapes();
    shape_reporter#(square)::report_shapes();
    shape_reporter#(triangle)::report_shapes();

end

endmodule : top
