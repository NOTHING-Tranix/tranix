package com.nothing.tranix.wallet.internal;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/** Minimal text-only PDF (Courier, A4, 60 lines per page) — enough for a simple statement without a library. */
final class SimplePdf {

    private static final int LINES_PER_PAGE = 60;

    private SimplePdf() {
    }

    static byte[] render(List<String> lines) {
        List<List<String>> pages = new ArrayList<>();
        for (int i = 0; i < Math.max(1, lines.size()); i += LINES_PER_PAGE) {
            pages.add(lines.subList(Math.min(i, lines.size()), Math.min(i + LINES_PER_PAGE, lines.size())));
        }
        List<String> objects = new ArrayList<>();
        objects.add("<< /Type /Catalog /Pages 2 0 R >>");
        StringBuilder kids = new StringBuilder();
        for (int p = 0; p < pages.size(); p++) {
            kids.append(4 + p * 2).append(" 0 R ");
        }
        objects.add("<< /Type /Pages /Kids [" + kids + "] /Count " + pages.size() + " >>");
        objects.add("<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>");
        for (int p = 0; p < pages.size(); p++) {
            objects.add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents "
                    + (5 + p * 2) + " 0 R >>");
            StringBuilder s = new StringBuilder("BT /F1 9 Tf 36 806 Td 12 TL\n");
            for (String line : pages.get(p)) {
                s.append('(').append(escape(line)).append(") Tj T*\n");
            }
            s.append("ET");
            byte[] content = s.toString().getBytes(StandardCharsets.ISO_8859_1);
            objects.add("<< /Length " + content.length + " >>\nstream\n" + s + "\nendstream");
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        write(out, "%PDF-1.4\n");
        List<Integer> offsets = new ArrayList<>();
        for (int i = 0; i < objects.size(); i++) {
            offsets.add(out.size());
            write(out, (i + 1) + " 0 obj\n" + objects.get(i) + "\nendobj\n");
        }
        int xref = out.size();
        StringBuilder x = new StringBuilder("xref\n0 " + (objects.size() + 1) + "\n0000000000 65535 f \n");
        offsets.forEach(o -> x.append(String.format("%010d 00000 n \n", o)));
        x.append("trailer\n<< /Size ").append(objects.size() + 1).append(" /Root 1 0 R >>\nstartxref\n").append(xref).append("\n%%EOF");
        write(out, x.toString());
        return out.toByteArray();
    }

    private static String escape(String s) {
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c == '(' || c == ')' || c == '\\') {
                b.append('\\').append(c);
            } else if (c < 32 || c > 126) {
                b.append('?');
            } else {
                b.append(c);
            }
        }
        return b.toString();
    }

    private static void write(ByteArrayOutputStream out, String s) {
        out.writeBytes(s.getBytes(StandardCharsets.ISO_8859_1));
    }
}
