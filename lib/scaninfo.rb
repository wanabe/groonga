class Expr
  def build(sis, var, op, size)
    i = 0
    stat = SCAN_START
    si = nil
    each do |c|
      case c.op
      when GRN_OP_MATCH, GRN_OP_NEAR, GRN_OP_NEAR2,
           GRN_OP_SIMILAR , GRN_OP_PREFIX, GRN_OP_SUFFIX,
           GRN_OP_EQUAL, GRN_OP_NOT_EQUAL, GRN_OP_LESS,
           GRN_OP_GREATER, GRN_OP_LESS_EQUAL,
           GRN_OP_GREATER_EQUAL, GRN_OP_GEO_WITHINP5,
           GRN_OP_GEO_WITHINP6, GRN_OP_GEO_WITHINP8,
           GRN_OP_TERM_EXTRACT
        stat = SCAN_START
        si.op = c.op
        si.fin = index c
        sis[i] = si
        i += 1
        si.each_arg do |arg|
          if arg.type == GRN_EXPR
            e = arg.to_expr
            eci = 0
            while eci < e.codes_curr
              ec = e[eci]
              if ec.value
                case ec.value.type
                when GRN_ACCESSOR
                  index, sid = ec.value.column_index c.op
                  if index
                    weight = ec.weight
                    si.flags |= SCAN_ACCESSOR
                    if ec.value.to_accessor.next
                      si.put_index ec.value, sid, weight
                    else
                      si.put_index index, sid, weight
                    end
                  end
                when GRN_COLUMN_FIX_SIZE , GRN_COLUMN_VAR_SIZE
                  index, sid = ec.value.column_index c.op
                  si.put_index index, sid, ec.weight if index
                when GRN_COLUMN_INDEX
                  index, sid = ec.value, 0
                  if e[eci + 2] &&
                     e[eci + 1].value &&
                     e[eci + 1].value.domain == GRN_DB_UINT32 &&
                     e[eci + 2].op == GRN_OP_GET_MEMBER
                    sid = e[eci + 1].value.inspect.to_i + 1
                    eci += 2
                    ec = e[eci]
                  end
                  si.put_index index, sid, ec.weight if index
                end
              end
              eci += 1
            end
          elsif arg.db?
            index, sid = arg.column_index c.op
            si.put_index index, sid, 1 if index
          elsif arg.accessor?
            si.flags |= SCAN_ACCESSOR
            index, sid = arg.column_index c.op
            if index
              if arg.to_accessor.next
                si.put_index arg, sid, 1
              else
                si.put_index index, sid, 1
              end
            end
          else
            si.query = arg
          end
        end
        si = nil
      when GRN_OP_AND, GRN_OP_OR, GRN_OP_AND_NOT,
           GRN_OP_ADJUST
        i = put_logical_op sis, i, c.op, index(c)
        stat = SCAN_START
      when GRN_OP_PUSH
        si = alloc_si sis, i, index(c) unless si
        if !si
          i = nil
        elsif c.value == var
          stat = SCAN_VAR
        else
          si.push_arg c.value
          si.flags |= SCAN_PRE_CONST if stat == SCAN_START
          stat == SCAN_CONST
        end
      when GRN_OP_GET_VALUE
        si = alloc_si sis, i, index(c) unless si
        case sis && stat
        when nil
          i = nil
        when SCAN_START, SCAN_CONST, SCAN_VAR
          stat = SCAN_COL1
          si.push_arg c.value
        when SCAN_COL1
          err GRN_INVALID_ARGUMENT,
              "invalid expression: can't use column" +
              " as a value: <#{c.value.name}>: " +
              "<#{inspect}>"
          sis.free i
          i = nil
        when SCAN_COL2
        end
      when GRN_OP_CALL
        si = alloc_si sis, i, index(c) unless si
        if !si
          i = nil
        elsif c.flags(GRN_EXPR_CODE_RELATIONAL_EXPRESSION) ||
              index(c) + 1 == codes_curr
          stat = SCAN_START
          si.op = c.op
          si.fin = index(c)
          sis[i] = si
          i += 1
          si.each_arg do |arg|
            if arg.db?
              index, sid = arg.column_index c.op
              si.put_index index, sid, 1 if index
            elsif arg.accessor?
              si.flags |= SCAN_ACCESSOR
              index, sid = arg.column_index c.op
              si.put_index index, sid, 1 if index
            else
              si.query = arg
            end
          end
          si = nil
        else
          stat = SCAN_COL2
        end
      end
      i
    end
    return nil unless i
    if op == GRN_OP_OR && size == 0
      si = sis[0]
      if si.flags & SCAN_PUSH == 0 || si.logical_op != op
        err GRN_INVALID_ARGUMENT, 'invalid expr'
        sis.free i
        return nil
      else
        si.flags &= ~SCAN_PUSH
        si.logical_op = op
      end
      return i
    else
      return put_logical_op sis, i, op, codes_curr
    end
  end
end
